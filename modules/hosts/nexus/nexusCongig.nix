{...}:
{
  flake.nixosModules.nexusConfig = {pkgs,...}: {


    networking = {
      hostName = "Nexus";
    };


    environment.systemPackages = with pkgs; [
      tor-browser
      tor
    ];

    programs.fuse.userAllowOther = true;
    services.org-sync = {
      enable = true;
      localPath = "/home/monad/org";
      remote = "myDropBox3.1:org";
      interval = "1m";
    };


    my.services.logitechs.enable = true;
  };


}
