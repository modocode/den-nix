{...}:

{

  flake.nixosModules.rclone-gdrive =
    {
      config,
      lib,
      pkgs,
      ...


    }:

    let
      cfg = config.services.rclone-gdrive;

    in

      options.services.rclone-gdrive = {
        enable = lib.mkEnableOption "Google Drive Syncing With Rclone";
      };
  config = lib.mkIf cfg.enable {
    systemd.user.services.rclone-gdrive = {
      Unit = {
        Description = "Google Drive rclone FUSE mount";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "notify";

        ExecStartPre =
          "${pkgs.coreutils}/bin/mkdir -p %h/mnt/gdrive";

        ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount \
          gdrive: %h/mnt/gdrive \
          --config=%h/.config/rclone/rclone.conf \
          --cache-dir=%h/.cache/rclone \
          --vfs-cache-mode=full \
          --vfs-cache-max-size=5G \
          --vfs-cache-max-age=24h \
          --dir-cache-time=10m \
          --poll-interval=1m
      '';

        ExecStop =
          "${pkgs.fuse3}/bin/fusermount3 -uz %h/mnt/gdrive";

        Restart = "on-failure";
        RestartSec = 10;
      };

      Install = {
        WantedBy = [ "default.target" ];
    };

  };
        
}
