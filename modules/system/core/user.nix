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
      zsh
    ];
  in {
    imports = modules;

    users.users.monad = {
      isNormalUser = true;
			shell = pkgs.zsh;
			ignoreShellProgramCheck = true; 
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = ["wheel" "podman" "networkmanager"];
    };


  };
}
