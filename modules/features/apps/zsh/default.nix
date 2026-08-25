{inputs, moduleWithSystem, ...}:

{

  flake.nixosModules.zsh = moduleWithSystem ({
    pkgs,
      self',
    ...
  }:

    {


      nixpkgs.overlays = [
        (final: prev: {
          zsh = self'.packages.myZsh;
        })
      ];

      users.defaultUserShell = self'.packages.myZsh;

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.highlighters = [
          "main"
          "brackets"
          "pattern"
          "regexp"
          "root"
          "line"

      ];

      setOptions = ["HIST_IGNORE_DUPS"];

      histSize = 10000;
      
      autosuggestions = {
        enable = true;
        highlightStyle = "fg=#6c7086,bg=none";
      };

      ohMyZsh = {
        enable = true;
        theme = "agnoster";
        plugins = [
          "${pkgs.zsh-fzf-tab}"
        ];


      };
    };
    });
      perSystem = {pkgs, self', lib, ...}:
        {
          packages.myZsh = let
            myShellAliases = {
              ll = "${lib.getExe pkgs.eza} --icons --group-directories-first -l";
              ls = "${lib.getExe pkgs.eza} --icons --group-directories-first";
              la = "${lib.getExe pkgs.eza} --icons --group-directories-first -la";
              lg = "${lib.getExe pkgs.eza} --icons --group-directories-first -la --git";
              lt = "${lib.getExe pkgs.eza} --icons --tree --level=2";
              cat = lib.getExe pkgs.bat;
              htop = lib.getExe pkgs.bottom;
              fd = "${lib.getExe pkgs.fd} -Lu";
              ns = "${lib.getExe self'.packages.nh} os switch . -H";
              nt = "${lib.getExe self'.packages.nh} os test . -H";
              cd = "z";
              nc = "${lib.getExe self'.packages.nh} clean all";

            };

            in 

              inputs.wrapper-modules.wrappers.zsh.wrap {
                inherit pkgs;
                runtimePkgs = [pkgs.fzf pkgs.zoxide];
                zshAliases = myShellAliases;

                zshrc.content = ''
        eval "$(${lib.getExe pkgs.zoxide} init zsh)"

        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
        bindkey '^P' history-beginning-search-backward
        bindkey '^N' history-beginning-search-forward

        gen-cpp() {
            echo "use flake" > .envrc
            direnv allow
            if [ ! -f main.cpp ]; then
                touch main.cpp
            fi
            echo "Created .envrc and main.cpp. Now open flake.nix and use your snippet!"

        }
                '';

              }; 



      };


  }


