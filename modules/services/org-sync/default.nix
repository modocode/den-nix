{ ... }:

{
  flake.nixosModules.orgSync =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      cfg = config.services.org-sync;

      orgFilter = pkgs.writeText "org-filter.txt" ''
        # Emacs lock files
        - .#*
        - **/.#*

        # Emacs auto-save files
        - #*#
        - **/#*#

        # Emacs backup files
        - *~
        - **/*~
      '';

      scriptConfig = ''
        local_path=${lib.escapeShellArg cfg.localPath}
        remote=${lib.escapeShellArg cfg.remote}
        filter_source=${lib.escapeShellArg (toString orgFilter)}
        remote_backup=${lib.escapeShellArg cfg.remoteBackupPath}
        state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/org-sync"
        work_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/rclone/bisync"
      '';

      orgSync = pkgs.writeShellApplication {
        name = "org-sync-run";
        runtimeInputs = [
          pkgs.rclone
          pkgs.coreutils
          pkgs.findutils
          pkgs.util-linux
        ];
        text = scriptConfig + builtins.readFile ./run.sh;
      };

      orgSyncPreview = pkgs.writeShellApplication {
        name = "org-sync-preview";
        text = ''
          exec ${lib.getExe orgSync} --dry-run "$@"
        '';
      };

      orgSyncDebug = pkgs.writeShellApplication {
        name = "org-sync-debug";
        runtimeInputs = [
          pkgs.rclone
          pkgs.coreutils
          pkgs.findutils
          pkgs.util-linux
          pkgs.systemd
        ];
        text = scriptConfig + builtins.readFile ./debug.sh;
      };

    in
    {
      options.services.org-sync = {
        enable = lib.mkEnableOption "Org directory synchronization";

        localPath = lib.mkOption {
          type = lib.types.str;
          default = "/home/monad/org";
          description = "Local Org directory.";
        };

        remote = lib.mkOption {
          type = lib.types.str;
          default = "myDropBox3.1:org";
          description = "rclone remote containing the Org directory.";
        };

        interval = lib.mkOption {
          type = lib.types.str;
          default = "5m";
          description = "Synchronization interval.";
        };

        remoteBackupPath = lib.mkOption {
          type = lib.types.str;
          default = "${cfg.remote}-backups";
          description = "Remote backup directory outside the synced tree. Replaced and deleted files are kept in dated subdirectories.";
        };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          pkgs.rclone
          orgSync
          orgSyncPreview
          orgSyncDebug
        ];

        systemd.user.services.org-sync = {
          description = "Synchronize Org files with Dropbox";

          serviceConfig = {
            Type = "oneshot";
            ExecStart = lib.getExe orgSync;
            TimeoutStartSec = "15m";
            TimeoutStopSec = "2m";
            KillSignal = "SIGINT";
          };
        };

        systemd.user.timers.org-sync = {
          description = "Periodically synchronize Org files with Dropbox";

          wantedBy = [
            "timers.target"
          ];

          timerConfig = {
            OnBootSec = "2m";
            OnUnitInactiveSec = cfg.interval;
            Unit = "org-sync.service";
          };
        };
      };
    };
}
