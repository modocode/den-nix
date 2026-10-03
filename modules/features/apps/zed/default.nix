{ moduleWithSystem, ... }:

{

  flake.homeModules.myZed = moduleWithSystem (
    { self', ... }:

    {pkgs, ... }:
    {
      programs.zed-editor = {
        enable = true;

        userSettings = {
          lsp = {
            nil = {
              binary = {
                path_lookup = true;
              };
              settings = {
                formatting = {
                  command = ["alejandra"];
                };
                diagnostics = {
                  ignored = [
                    "unused_binding"
                  ];
                };
              };
            };
          };

          vim_mode = true;
          load_direnv = "shell_hook";
        };
        extensions = [
          "nix"
          "live-server"
          "colored-zed-icons-theme"
          "zig"
        ];
 
        userKeymaps = [
            {
              context = "Workspace";
              bindings = {
                ctrl-shift-t = "workspace::NewTerminal";
              };
            }
          ];
      };
    }
    
  );
}
