{self, moduleWithSystem, ...}:

{

  flake.nixosModules.desktop = moduleWithSystem({pkgs, ...}:

    let
      modules = with self.nixosModules; [
        core
        #kde-plasma
        network
        niri
        zen-browser
        fonts

        
      ];
    in {
      imports = modules;
      environment.systemPackages = [
        #pkgs.kdePackages.spectacle
      ];

    });


}
