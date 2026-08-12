{inputs, moduleWithSystem, ...}:

{

  perSystem = {pkgs, ...}:{

    packages.myFuzzel = inputs.wrapper-modules.wrappers.fuzzel.wrap {
      inherit pkgs;
      settings = {
            main = {
              terminal = "${pkgs.alacritty}/bin/alacritty";
              width = 40;
              lines = 15;
              horizontal-pad = 20;
              vertical-pad = 12;
            };

            colors = {
              background = "1e1e2eff";
              text = "cdd6f4ff";
              match = "f5c2e7ff";
              selection = "313244ff";
              
              selection-text = "cdd6f4ff";
            };
          };

    };


  };

  flake.homeModules.fuzzel = moduleWithSystem(
    {self', ...}:
    {...}:

    {
      home.packages = [
        self'.packages.myFuzzel
      ];

    }

  );

}
