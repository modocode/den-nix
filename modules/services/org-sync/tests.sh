#!/usr/bin/env bash
set -euo pipefail

# Integration tests use temporary local directories; no Dropbox credentials or network.
module_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/org-sync-tests.XXXXXXXX")
trap 'rm -rf -- "$test_dir"' EXIT
mkdir -p "$test_dir/local/sub" "$test_dir/remote" "$test_dir/state" "$test_dir/cache"
cat >"$test_dir/filter.txt" <<'EOF'
- .#*
- **/.#*
- #*#
- **/#*#
- *~
- **/*~
EOF
for name in note.org inbox.org journal.org sub/project.org; do
  printf 'saved contents\n' >"$test_dir/local/$name"
done
printf 'unsaved auto-save\n' >"$test_dir/local/#note.org#"
printf 'backup\n' >"$test_dir/local/sub/project.org~"
ln -s missing-emacs-process "$test_dir/local/.#note.org"

run_sync() {
  env local_path="$test_dir/local" remote="$test_dir/remote" \
    remote_backup="$test_dir/remote-backups" filter_source="$test_dir/filter.txt" \
    state_dir="$test_dir/state" work_dir="$test_dir/cache" \
    bash -euo pipefail "$module_dir/run.sh" "$@"
}

rclone bisync "$test_dir/local" "$test_dir/remote" --resync \
  --workdir "$test_dir/cache" --filter-from "$test_dir/filter.txt"
run_sync
cmp "$test_dir/local/note.org" "$test_dir/remote/note.org"
test ! -e "$test_dir/remote/#note.org#"
test ! -e "$test_dir/remote/sub/project.org~"
test ! -L "$test_dir/remote/.#note.org"
echo 'PASS: migrate an existing filter-from baseline and exclude Emacs temporary files and dangling locks'

printf 'saved edit\n' >"$test_dir/local/note.org"
touch -d '2030-01-01' "$test_dir/local/note.org"
find "$test_dir/cache" "$test_dir/state" -type f -exec sha256sum '{}' + | sort >"$test_dir/before"
run_sync --dry-run
find "$test_dir/cache" "$test_dir/state" -type f -exec sha256sum '{}' + | sort >"$test_dir/after"
cmp "$test_dir/before" "$test_dir/after"
test "$(cat "$test_dir/remote/note.org")" = 'saved contents'
run_sync --dry-run --resync
find "$test_dir/cache" "$test_dir/state" -type f -exec sha256sum '{}' + | sort >"$test_dir/after-resync"
cmp "$test_dir/before" "$test_dir/after-resync"
test "$(cat "$test_dir/remote/note.org")" = 'saved contents'
echo 'PASS: preview changes neither live state nor remote files'

run_sync
cmp "$test_dir/local/note.org" "$test_dir/remote/note.org"
test -n "$(find "$test_dir/remote-backups" -name note.org -print -quit)"
echo 'PASS: propagate saved edits and back up the replaced remote version'

rm "$test_dir/local/journal.org"
run_sync
test ! -e "$test_dir/remote/journal.org"
test -n "$(find "$test_dir/remote-backups" -name journal.org -print -quit)"
echo 'PASS: preserve deleted remote files in backups'

printf 'local simultaneous edit\n' >"$test_dir/local/note.org"
printf 'remote simultaneous edit\n' >"$test_dir/remote/note.org"
touch -d '2031-01-01' "$test_dir/local/note.org"
touch -d '2032-01-01' "$test_dir/remote/note.org"
run_sync
for side in local remote; do
  grep -rlFx 'local simultaneous edit' "$test_dir/$side" >/dev/null
  grep -rlFx 'remote simultaneous edit' "$test_dir/$side" >/dev/null
done
echo 'PASS: simultaneous saved conflicts preserve both versions on both sides'

printf 'remote saved edit\n' >"$test_dir/remote/inbox.org"
touch -d '2033-01-01' "$test_dir/remote/inbox.org"
run_sync
cmp "$test_dir/local/inbox.org" "$test_dir/remote/inbox.org"
test -n "$(find "$test_dir/state/backups" -name inbox.org -print -quit)"
echo 'PASS: remote edits back up the replaced local version'

cp "$test_dir/filter.txt" "$test_dir/filter-original.txt"
echo '- inbox.org' >>"$test_dir/filter.txt"
if run_sync --dry-run; then
  echo 'FAIL: changed filters should require resync' >&2
  exit 1
fi
cp "$test_dir/filter-original.txt" "$test_dir/filter.txt"
echo 'PASS: changed filters trigger a safety abort'

exec 8>"$test_dir/state/run.lock"
flock --nonblock 8
if run_sync --dry-run; then
  echo 'FAIL: overlapping wrapper commands should be blocked' >&2
  exit 1
fi
flock --unlock 8
echo 'PASS: overlapping commands are blocked'

mkdir "$test_dir/mock-bin"
printf '#!/usr/bin/env bash\nprintf "%%s fuse.rclone\\n" "$local_path"\n' >"$test_dir/mock-bin/findmnt"
chmod +x "$test_dir/mock-bin/findmnt"
if PATH="$test_dir/mock-bin:$PATH" run_sync --dry-run; then
  echo 'FAIL: mounted rclone directory should be blocked' >&2
  exit 1
fi
echo 'PASS: rclone mount is rejected before sync'
