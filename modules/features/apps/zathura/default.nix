{ self, ... }:

{
  flake.nixosModules.zathura =
    { pkgs, ... }:
    {
      environment.systemPackages  = [
        pkgs.zathura
      ];
    };
}
