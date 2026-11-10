{self, moduleWithSystem, inputs, ...}:

{

  flake.nixosModules.desktop = {pkgs, ...}:

    {
    imports = [
        self.nixosModules.core
        # self.nixosModules.kde-plasma
        self.nixosModules.network
        self.nixosModules.niri
        self.nixosModules.zen-browser
        self.nixosModules.fonts
        self.nixosModules.ghostty
    ];
    

        
      environment.systemPackages = [
        #pkgs.kdePackages.spectacle
        # inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
        pkgs.peazip
        pkgs.nautilus
        pkgs.fastfetch
        # pkgs.firefox-bin
        # pkgs.firefox-bin-unwrapped
        # pkgs.google-chrome
        pkgs.brave
      ];

    };


}
