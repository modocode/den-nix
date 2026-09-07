{self, moduleWithSystem, ...}:

{

  flake.nixosModules.desktop = moduleWithSystem({pkgs, ...}:

    {
    imports = [
        self.nixosModules.core
        self.nixosModules.kde-plasma
        self.nixosModules.network
        # self.nixosModules.niri
        self.nixosModules.zen-browser
        self.nixosModules.fonts
        self.nixosModules.ghostty
       # self.nixosModules.kde-plasma
    ];
    

        
      environment.systemPackages = [
        #pkgs.kdePackages.spectacle
        pkgs.peazip
        pkgs.nautilus
      ];

    });


}
