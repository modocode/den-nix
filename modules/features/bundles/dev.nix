{self, moduleWithSystem, ...}:

{

  flake.nixosModules.dev = moduleWithSystem({pkgs, ...}:

    let
      modules = with self.nixosModules; [
        # Add Modules
        emacs
        git
        nh
        zsh

        /*
          to add as needed

          scientific
          eda
          fpga
          embedded



        */

      ];
    in {
      imports = modules;
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
