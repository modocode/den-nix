{self, moduleWithSystem, ...}:

{

  flake.nixosModules.office = moduleWithSystem({pkgs, ...}:
    {
      imports = [
        self.nixosModules.libreoffice

      ];


      home-manager.sharedModules = [
        self.homeModules.thunderbird
      ];

      environment.systemPackages = with pkgs; [
        # simple office utilities
      ];


    });



}



