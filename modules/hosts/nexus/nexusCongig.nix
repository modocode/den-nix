{...}:

{
  flake.nixosModules.nexusConfig = {pkgs,...}: {


    networking = {
      hostName = "Nexus";
    };


    environment.systemPackages = with pkgs; [
      tor-browser
      tor
      rclone
    ];


  };


}
