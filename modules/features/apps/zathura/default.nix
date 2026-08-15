{ self, ... }:

{
  flake.nixosModules.zathura =
    { pkgs, ... }:
    {
      enviornment.systemPackages  = [
        pkgs.zathura
      ];
    };
}
