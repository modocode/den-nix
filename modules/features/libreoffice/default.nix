{ self, ... }:

{
  flake.nixosModules.libreoffice =
    { pkgs, ... }:
    {
      enviornment.systemPackages = [
        pkgs.libreoffice
      ];
    };
}
