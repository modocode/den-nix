{ self, ... }:

{
  flake.nixosModules.libreoffice =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.libreoffice
      ];
    };
}
