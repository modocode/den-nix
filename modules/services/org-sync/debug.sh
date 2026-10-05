if [[ $# -gt 1 || ( $# -eq 1 && "$1" != --remote && "$1" != --help ) ]]; then
  echo "Usage: org-sync-debug [--remote]" >&2
  exit 2
fi
if [[ "${1:-}" == --help ]]; then
  echo "Usage: org-sync-debug [--remote]"
  echo "Print service, mount and sync-state diagnostics; --remote also lists remote filenames."
  exit 0
fi
cd "$HOME"

printf 'Org sync diagnostics: %s\nLocal: %s\nRemote: %s\nRemote backups: %s\n' \
  "$(date --iso-8601=seconds)" "$local_path" "$remote" "$remote_backup"
rclone version

echo '--- Service and timer ---'
systemctl --user status org-sync.service org-sync.timer --no-pager || true
systemctl --user show org-sync.service -p LoadState -p LoadError -p FragmentPath -p ExecStart || true
systemctl --user list-timers org-sync.timer --all --no-pager || true
systemctl --user cat org-sync.service org-sync.timer || true

echo '--- User unit overrides (dangling links can shadow the NixOS unit) ---'
unit_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
for unit in org-sync.service org-sync.timer; do
  if [[ -e "$unit_dir/$unit" || -L "$unit_dir/$unit" ]]; then
    ls -ld -- "$unit_dir/$unit"
    if [[ -L "$unit_dir/$unit" && ! -e "$unit_dir/$unit" ]]; then
      echo "BROKEN SYMLINK: $unit_dir/$unit"
    fi
  fi
done

echo '--- Mounts ---'
findmnt --raw --noheadings --output TARGET,SOURCE,FSTYPE || true
systemctl --user status rclone-dropbox.service --no-pager || true

echo '--- Local files (names only; no file contents) ---'
find "$local_path" -type f -printf '%P\n' | sort || true
echo '--- Symlinks (including Emacs locks; normal sync does not follow symlinks) ---'
find "$local_path" -type l -printf '%P -> %l\n' || true

echo '--- Filters ---'
cat "$filter_source"
echo '--- Saved bisync state ---'
ls -lah -- "$work_dir" || true
echo '--- Bisync locks (inspect the recorded PID before removing a stale lock) ---'
find "$work_dir" -maxdepth 1 -type f -name '*.lck' -print -exec cat '{}' \; || true
echo '--- Filter checksum recorded by the wrapper ---'
cat "$state_dir/filter.sha256" 2>/dev/null || true
echo '--- Last successful run with the new wrapper ---'
cat "$state_dir/last-success" 2>/dev/null || true
echo '--- Recent service logs ---'
journalctl --user -u org-sync.service -n 100 --no-pager || true

if [[ "${1:-}" == --remote ]]; then
  echo '--- Remote files (names only) ---'
  rclone lsf "$remote" --recursive --contimeout 20s --timeout 1m
fi
