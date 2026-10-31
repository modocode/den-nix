{inputs, moduleWithSystem,lib, ...}:

{

  flake.nixosModules.zsh = moduleWithSystem ({
    pkgs,
      self',
    ...
  }:

    let
      macosThemeSrc = pkgs.fetchFromGitHub {
        owner = "alejandromume";
        repo = "macos-zsh-theme";
        rev = "783b8f596920df05144cf1df6918720179615cae";
        hash = "sha256-AoIBqhufvZk4lEAORcjWy6e0FiXC7iqneWtyhAZCM2k=";

      };

       macosTheme = pkgs.runCommand "macos-zsh-theme" {} ''
        mkdir -p $out/share/zsh/themes/macos-zsh-theme

        cp ${macosThemeSrc}/macos-theme.zsh-theme \
          $out/share/zsh/themes/macos-zsh-theme/
      '';

      in 
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
      # syntaxHighlighting.highlighters = [
      #     "main"
      #     "brackets"
      #     "pattern"
      #     "regexp"
      #     "root"
      #     "line"

      # ];

      setOptions = ["HIST_IGNORE_DUPS"];

      histSize = 10000;
      
      autosuggestions = {
        enable = true;
        # highlightStyle = "fg=#6c7086,bg=none";
        highlightStyle = "fg=#8fa832,bg=grey,bold,underline";

      };

      ohMyZsh = {
        enable = true;
        theme = "macos-zsh-theme/macos-theme";
        customPkgs = [macosTheme];
        plugins = [
          "zsh-interactive-cd"
          "aliases"
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
              cd = "cd";
              nc = "${lib.getExe self'.packages.nh} clean all";

              
              nf = "nix flake show";
              nfc = "nix flake check";
              nfu = "nix flake update";

              
              nsearch = "nix search nixpkgs";
              ninfo = "nix derivation show";
              nwhy = "nix why-depends";
              nlog = "nix log";
              
              ne = "nix eval";
              nb = "nix build";
              nfmt = "${lib.getExe pkgs.alejandra}";

              ng = "sudo nixos-rebuild list-generations";

            };

            in 

              inputs.wrapper-modules.wrappers.zsh.wrap {
                inherit pkgs;
                runtimePkgs = [pkgs.fzf pkgs.zoxide];
                zshAliases = myShellAliases;
                zshrc.path = "~/.zshrc";

                zshrc.content = ''
        eval "$(${lib.getExe pkgs.zoxide} init zsh)"

        #source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
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
          nfetch() {
              if (( $# != 2 )); then
                echo "Usage: nfetch <owner> <repo>"
                return 1
              fi
          
              local owner="$1"
              local repo="$2"
              local url="https://github.com/''${owner}/''${repo}.git"
              local rev hash
          
              rev=$(git ls-remote "$url" HEAD | awk '{print $1}')
          
              if [[ -z "$rev" ]]; then
                echo "Could not resolve repository HEAD" >&2
                return 1
              fi
          
              hash=$(nix store prefetch-file \
                --unpack --json \
                "https://github.com/''${owner}/''${repo}/archive/''${rev}.tar.gz" \
                | jq -r '.hash') || return 1
          
              printf '\n'
              printf 'pkgs.fetchFromGitHub {\n'
              printf '  owner = "%s";\n' "$owner"
              printf '  repo = "%s";\n' "$repo"
              printf '  rev = "%s";\n' "$rev"
              printf '  hash = "%s";\n' "$hash"
              printf '};\n'
            }
          

              


                ''


                ;

              }; 



      };


  }


