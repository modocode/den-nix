{self, moduleWithSystem, ...}:

{

  flake.nixosModules.office = moduleWithSystem({pkgs, ...}:
    {
      imports = [
        self.nixosModules.office-pdf
        self.nixosModules.office-documents
        # self.nixosModules.references
      ];


      home-manager.sharedModules = [
          self.homeModules.thunderbird
      ];

      environment.systemPackages = with pkgs; [
        # simple office utilities
        zotero
        pdf4qt
      ];


    });



}



