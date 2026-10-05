# Org synchronization

`~/org` must be an ordinary local directory. The old `rclone-dropbox.service`
mounts Dropbox's `OrgNotes2` over it and must stay disabled. The configured
sync pair is `/home/monad/org` and `myDropBox3.1:org`.

After rebuilding NixOS, these commands are available:

```sh
org-sync-debug                     # Units, mounts, filters, filenames, state and logs
org-sync-debug --remote            # Also list files in the configured remote
org-sync-debug > ~/org-sync-debug.txt
org-sync-preview                   # Preview ordinary synchronization
org-sync-preview --resync          # Preview rebuilding the bisync baseline
```

Reports include filenames and journal messages, but do not print rclone credentials
or Org file contents. Review a report before sharing it.

Previews operate on a temporary copy of the bisync listings, leaving the live
baseline and filter checksums unchanged. They contact the configured remote.
The wrapper rejects unknown arguments, overlapping wrapper runs and rclone mounts
that cover the local directory or any directory beneath it.

## Emacs editing

Only saved files are synchronized. Unsaved buffer changes cannot be read by rclone.
Emacs lock files (`.#*`), auto-save files (`#*#`) and backups (`*~`) are excluded
at every directory level. An open or modified buffer does not pause synchronization.
Save buffers before expecting their latest contents on another device. If another
device changes a file while you have unsaved edits, Emacs may need you to reconcile
the buffer with the new on-disk version. Bisync keeps both versions of simultaneous
saved conflicts using its default conflict handling. Symlinks are not followed.

## Backups and failures

Replaced and deleted local files are backed up under
`${XDG_STATE_HOME:-$HOME/.local/state}/org-sync/backups/<run-id>/`.
Remote versions are backed up in `services.org-sync.remoteBackupPath`, which defaults
to `myDropBox3.1:org-backups`, in dated subdirectories. Backups are kept indefinitely;
they consume disk space and Dropbox quota. The backup directory must be outside
the synced directory on the same rclone remote.

The existing `${XDG_CACHE_HOME:-$HOME/.cache}/rclone/bisync` baseline is retained.
The wrapper records a filter checksum after successful runs, retaining compatibility
with the existing `--filter-from` baseline. After the first successful wrapper run,
filter changes require a reviewed resync. The timer retries
after the configured interval following each completed or failed run. Network
operations have bounded timeouts, with up to three bisync attempts. Service runs
are limited to 15 minutes and get two minutes to shut down using rclone's SIGINT
graceful shutdown. Sync decisions and
errors are written to the user journal; successful wrapper runs also update
`~/.local/state/org-sync/last-success` (or its XDG equivalent).

For a failed sync:

```sh
org-sync-debug
org-sync-preview
journalctl --user -u org-sync.service -f
```

For a safety abort, confirm the correct directory and remote before proceeding.
Do not add `--force` to the timer or automatically resync after every failure.

## Manual recovery

Stop the timer, save buffers, and back up both directories before rebuilding the
baseline. A resync can restore previously deleted files and overwrites differing
files using the local version by default. Inspect the preview first:

```sh
systemctl --user stop org-sync.timer org-sync.service
org-sync-preview --resync
# Only after reviewing the preview and backing up both sides:
org-sync-run --resync
# After a successful recovery:
systemctl --user start org-sync.service && systemctl --user restart org-sync.timer
```

The debug scripts deliberately do not remove unit overrides, unmount filesystems,
delete lock files, force deletions, or execute recovery automatically.

## Verification

```sh
bash modules/services/org-sync/tests.sh
```

Tests use temporary local directories with real rclone bisync, without contacting
Dropbox. They cover Emacs exclusions, saved edits, remote backups, deletions,
isolated previews, changed filters, overlapping commands and the mount guard.

New `.sh` files must be tracked by Git for a Git-backed flake evaluation to include
them. Alternatively, build with `--flake path:/home/monad/den-nix#nexus` while
reviewing untracked files.
