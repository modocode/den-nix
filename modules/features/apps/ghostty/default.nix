{
  flake.homeModules.ghostty =
    { pkgs,lib, ... }:
    {
      programs.ghostty = {
        enable = true;

        enableZshIntegration = true;
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
