{ inputs, moduleWithSystem, ... }:

{
  flake.nixosModules.ghostty = moduleWithSystem (
    { self', ... }:

    { ... }:
    {
      programs.ghossty = {
        enable = true;
        package = self'.packages.myGhostty;
      };
      
    }
  );

  perSystem =
    { pkgs, ... }:
    {
      packages.myGhostty =
        inputs.wrapper-modules.wrappers.ghostty.wrap {
          inherit pkgs;

          settings = {
            font-size = 14;
            theme = "Catppuccin Mocha";
            window-decoration = false;
            cursor-style = "bar";
            keybind = [
              "ctrl+a>-=new_split:down"
              "ctrl+a>==new_split:right"
            ];

          };
          
        };
    };
}
