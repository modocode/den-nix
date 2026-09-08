{
  flake.homeModules.myVicinae = moduleWithSystem (
  { pkgs, ... }:

  {...}:
  {


      imports = [
        inputs.vicinae.homeManagerModules.default
      ];

      programs.vicinae = {
        enable = true;
        systemd = {
          enable = true; # default: false
          autoStart = true; # default: true (if systemd.enable is true)
          environment = {
            USE_LAYER_SHELL = 1;
          };
        };

        settings = {
          close_on_focus_loss = true;
          consider_preedit = true;
          pop_to_root_on_close = true;
          search_files_in_root = true;
         
        };

        extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
          bluetooth
          nix
          power-profile
          # Extension names can be found in the link below, it's just the folder names
        ];
    };
}


  );
