{ inputs, moduleWithSystem, ... }:

{
  flake.nixosModules.ghostty = moduleWithSystem (
    { self', ... }:

    { ... }:
    {
      
    }
  );

  perSystem =
    { lib, pkgs, self',  ... }:
    {
      packages.myGhostty =
        inputs.wrapper-modules.wrappers.ghostty.wrap {
          inherit pkgs;

          settings = {
            font-size = 12;
            theme = "Tearout";
            window-decoration = false;
            shell-integration = "zsh";
            font-family = "SFMono Nerd Font";
            background-opacity = 0.85;
            background-blur = true;
            command = lib.getExe self'.packages.myZsh;
            cursor-style = "bar";
            keybind = [
              "ctrl+a>-=new_split:down"
              "ctrl+a>==new_split:right"
            ];

          };
          
        };
    };
}
