{
  flake = {
    nixosModules.starship = {
      programs.starship = {
        enable = true;
        transientPrompt.enable = true;
        settings = {
          scan_timeout = 10;
          add_newline = true;
          command_timeout = 200;
        };
      };
    };
    homeModules.starship = { ... }: {
      programs.starship = {
        enable = true;
        enableZshIntegration = true;
        presets = [ "nerd-font-symbols" ];
      };
    };
  };
}
