{ moduleWithSystem, ... }:

{

  flake.homeModules.myVscodium = moduleWithSystem (
    { self', ... }:

    {pkgs, ... }:
    {
      programs.vscodium = {
        enable = true;
        profiles = {
          monad = {
            extensions = [
              pkgs.vscode-extensions.vscodevim.vim
              pkgs.vscode-extensions.ms-vscode.live-server
              pkgs.vscode-extensions.chris-hayes.chatgpt-reborn
            ];

            userSettings = {
              "[nix]" = {
                "editor.tabSize" = 2;
              };
              "files.autoSave" = "off";

            };

          };

        };

      };
      
    }
  );
}
