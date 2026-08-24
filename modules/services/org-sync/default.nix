{ ... }:

{
  flake.nixosModules.orgSync =
    { config, lib, pkgs, ... }:

    let
      cfg = config.services.org-sync;

      orgFilter = pkgs.writeText "org-filter.txt" ''
        # Emacs lock files
        - **/.#*

        # Emacs auto-save files
        - **/#*#

        # Emacs backup files
        - **/*~
      '';

      orgSync = pkgs.writeShellScript "org-sync" ''
        #!${pkgs.bash}/bin/bash
        set -euo pipefail

        exec ${pkgs.rclone}/bin/rclone bisync \
          "${cfg.localPath}" \
          "${cfg.remote}" \
          --filter-from "${orgFilter}"
      '';

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
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          pkgs.rclone
        ];

        systemd.user.services.org-sync = {
          description = "Synchronize Org files with Dropbox";

          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${orgSync}";
          };
        };

        systemd.user.timers.org-sync = {
          description = "Periodically synchronize Org files with Dropbox";

          wantedBy = [
            "timers.target"
          ];

          timerConfig = {
            OnBootSec = "2m";
            OnUnitActiveSec = cfg.interval;
            Unit = "org-sync.service";
          };
        };
      };
    };
}
