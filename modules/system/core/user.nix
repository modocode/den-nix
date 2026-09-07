{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.user = {
    pkgs,
    lib,
    ...
  }:let
    modules = with self.nixosModules; [
      # zsh
    ];
  in {
    imports = modules;

    users.users.monad = {
      isNormalUser = true;
			shell = lib.getExe pkgs.zsh;
			ignoreShellProgramCheck = true; 
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = ["wheel" "podman" "networkmanager"];
    };


  };
  flake.homeModules.user =
    { ... }:
    {
      home = {
        username = "monad";
        homeDirectory = "/home/monad";
        stateVersion = "23.05";
      };

      programs.home-manager.enable = true;
    };

}
