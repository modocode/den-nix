{self, moduleWithSystem, ...}:

{

  flake.nixosModules.desktop = moduleWithSystem({pkgs, ...}:

    {
    imports = [
        self.nixosModules.core
        #kde-plasma
        self.nixosModules.network
        self.nixosModules.niri
        self.nixosModules.zen-browser
        self.nixosModules.fonts
       # self.nixosModules.kde-plasma
    ];
    

        
      environment.systemPackages = [
        #pkgs.kdePackages.spectacle
        pkgs.peazip
      ];

    });


}
