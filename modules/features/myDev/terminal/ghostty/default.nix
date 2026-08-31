{ inputs, moduleWithSystem, ... }:

{
  flake.nixosModules.ghostty = moduleWithSystem (
    { self', ... }:

    { ... }:
    {
      
    }
  );

  perSystem =
    { pkgs, ... }:
    {
      packages.myGhostty =
        inputs.wrapper-modules.wrappers.ghostty.wrap {
          inherit pkgs;

          settings = {
            font-size = 12;
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
