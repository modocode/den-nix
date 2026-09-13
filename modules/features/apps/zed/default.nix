{ moduleWithSystem, ... }:

{

  flake.homeModules.myZed = moduleWithSystem (
    { self', ... }:

    {pkgs, ... }:
    {
      programs.zed-editor = {
        enable = true;

        extensions = [
          "nix"
          "live-server"
          "colored-zed-icons-theme"
          "zig"
        ];
 
        userKeymaps = 
          [
            {
              context = "Workspace";
              bindings = {
                ctrl-shift-t = "workspace::NewTerminal";
              };
            };
          ];


      };

    };
    
  );
}
