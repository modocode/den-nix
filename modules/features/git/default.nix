{self, inputs, ...}:

{


  flake.nixosModules.git = {pkgs, lib, ...}: {
    programs.git = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.git;
    };

    programs.lazygit = {
      enable = true;
      settings = {
        gui.theme = {
          lightTheme = true;
          activeBorderColor = [ "blue" "bold" ];
          inactiveBorderColor = [ "black" ];
          selectedLineBgColor = [ "default" ];
        };

      };
    };

    
  };


  perSystem = {pkgs, ...}:
    {
      packages.git = inputs.wrapper-modules.wrappers.git.wrap {
        inherit pkgs;

        settings = {
          user = {
            name = "modocode";
            email = "colonialmediax@gmail.com";
          };
          core = {
            compression = 7;
            whitespace = "trailing-space";
            preloadindex = true;         
        };
        url = {
          "git@github.com:" = {
            insteadOf = "gh:";
          };

          init = {
            defaultBranch = "main";

          };


        };



      };



    };

    };
}
