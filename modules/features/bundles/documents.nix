{ self, ... }:

{
  flake.nixosModules.office-documents =
    { pkgs, ... }:
    {
      imports = [
        # self.nixosModules.libreoffice
        
      ];

      environment.systemPackages = [
        pkgs.pandoc
        pkgs.onlyoffice-desktopeditors
      ];
    };
}
