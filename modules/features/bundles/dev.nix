{self, moduleWithSystem, ...}:

{

  flake.nixosModules.dev = moduleWithSystem({pkgs, ...}:
    {
    imports = [
        # Add Modules
        self.nixosModules.emacs
        self.nixosModules.git
        self.nixosModules.nh
        self.nixosModules.zsh
        self.nixosModules.scientific
        self.nixosModules.eda
        self.nixosModules.fpga

        /*
          to add as needed

          scientific
          eda
          fpga
          embedded



        */
    ];

      home-manager.sharedModules = [


      ];


      
      environment.systemPackages = with pkgs; [
        wget
        ripgrep
        cmake
        ninja
        gnumake
        jq
      ];
      

    });


}
