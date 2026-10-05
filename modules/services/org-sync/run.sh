# Configuration and strict shell options are supplied by writeShellApplication.
dry_run=false
resync=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=true ;;
    --resync) resync=true ;;
    --help)
      echo "Usage: org-sync-run [--dry-run] [--resync]"
      echo "Prefer org-sync-preview for diagnosis. --resync rebuilds state and prefers local files on conflicts."
      exit 0
      ;;
    *) echo "Unknown argument: $arg" >&2; exit 2 ;;
  esac
done

cd "$HOME"
umask 077

# Inspect kernel mount information before touching a potentially disconnected FUSE directory.
mounts=$(findmnt --raw --noheadings --output TARGET,FSTYPE)
while read -r mount_target mount_type; do
  printf -v mount_target '%b' "$mount_target"
  if [[ "$mount_type" == fuse.rclone ]] &&
    [[ "$local_path/" == "$mount_target/"* || "$mount_target/" == "$local_path/"* ]]; then
    echo "Refusing to sync: rclone mount at $mount_target overlaps $local_path." >&2
    echo "Stop the mount service and unmount it, then run org-sync-debug." >&2
    exit 1
  fi
done <<<"$mounts"

# Also detect a configured path that reaches the mount through a directory symlink.
local_mount_type=$(findmnt --noheadings --output FSTYPE --target "$local_path")
if [[ "$local_mount_type" == fuse.rclone ]]; then
  echo "Refusing to sync: $local_path resolves into an rclone mount." >&2
  exit 1
fi

if [[ ! -d "$local_path" || ! -r "$local_path" || ! -w "$local_path" ]]; then
  echo "Local directory is missing or not readable/writable: $local_path" >&2
  exit 1
fi
# Detect inaccessible directory contents before interpreting a failed listing as deletions.
find "$local_path" -type f -printf '' >/dev/null

mkdir -p "$state_dir" "$work_dir"
exec 9>"$state_dir/run.lock"
if ! flock --nonblock 9; then
  echo "Another org-sync command is running; retry after it finishes." >&2
  exit 1
fi

preview_dir=""
cleanup() {
  if [[ -n "$preview_dir" ]]; then
    rm -rf -- "$preview_dir"
  fi
}
trap cleanup EXIT

# Track filters ourselves so existing --filter-from baselines remain usable.
# Changing to --filters-file would require a resync even with identical rules.
filter_hash=$(sha256sum "$filter_source")
filter_hash="${filter_hash%% *}"
if [[ -f "$state_dir/filter.sha256" ]] && ! "$resync" &&
  [[ "$(cat "$state_dir/filter.sha256")" != "$filter_hash" ]]; then
  echo "Filters changed since the last successful run; a reviewed --resync is required." >&2
  exit 1
fi

# Keep live bisync listings untouched during diagnostic previews.
if "$dry_run"; then
  preview_dir=$(mktemp -d "${TMPDIR:-/tmp}/org-sync-preview.XXXXXXXX")
  cp -a "$work_dir/." "$preview_dir/"
  work_dir="$preview_dir"
fi

run_id=$(date -u +%Y%m%dT%H%M%S)-$$
args=(
  bisync "$local_path" "$remote"
  --workdir "$work_dir"
  --filter-from "$filter_source"
  --recover --resilient
  --retries 3 --retries-sleep 10s
  --contimeout 20s --timeout 1m
  --log-level INFO
  --backup-dir1 "$state_dir/backups/$run_id"
  --backup-dir2 "$remote_backup/$run_id"
)
if "$dry_run"; then args+=(--dry-run); fi
if "$resync"; then args+=(--resync); fi

printf 'Org sync: local=%s remote=%s dry-run=%s resync=%s\n' "$local_path" "$remote" "$dry_run" "$resync"
if rclone "${args[@]}"; then
  if ! "$dry_run"; then
    printf '%s\n' "$filter_hash" >"$state_dir/filter.sha256"
    date --iso-8601=seconds >"$state_dir/last-success"
  fi
  echo "Org sync completed successfully."
else
  result=$?
  echo "Org sync failed (exit $result). Run org-sync-debug and org-sync-preview." >&2
  echo "If recovery requires --resync, back up both sides and review org-sync-preview --resync first." >&2
  exit "$result"
fi
