{ inputs, ... }:

let
  mkLearningPackage = pkgs:
    let
      inherit (pkgs) lib;
      rawPi = inputs.pi.packages.${pkgs.stdenv.hostPlatform.system}.coding-agent;
      resources = pkgs.runCommand "pi-learning-resources" { } ''
        mkdir -p $out
        cp -R ${./learn}/. $out/
      '';
      tutor = inputs.pi.lib.mkCodingAgent {
        inherit pkgs;
        modules = [{
          pi.coding-agent = {
            package = rawPi;
            rules = ./learn/rules.md;
            skills = [
              (resources + "/skills/teach")
              (resources + "/skills/visualize")
            ];
            extensions = [
              (resources + "/extensions/interactive-subagents/index.ts")
              (resources + "/extensions/ask-user-question.ts")
              (resources + "/extensions/quiz.ts")
              (resources + "/extensions/md-log.ts")
              (resources + "/extensions/research/index.ts")
              (resources + "/extensions/visual-tools/index.ts")
              (resources + "/extensions/learning/index.ts")
            ];
            # Keep personal authentication/model settings. Load only this
            # harness's executable extensions; explicit paths still load.
            extraArgs = [ "--no-extensions" "--no-prompt-templates" ];
          };
        }];
      };
    in pkgs.writeShellApplication {
      name = "pi-learn";
      runtimeInputs = [ pkgs.tmux pkgs.nodejs pkgs.mermaid-cli pkgs.chromium pkgs.librsvg ];
      text = ''
        export PI_LEARN_AGENTS_DIR=${lib.escapeShellArg "${resources}/agents"}
        export PI_LEARN_PI_BIN=${lib.escapeShellArg "${rawPi}/bin/pi"}
        export PI_LEARN_MMDC=${lib.escapeShellArg "${pkgs.mermaid-cli}/bin/mmdc"}
        export PI_LEARN_CHROMIUM=${lib.escapeShellArg "${pkgs.chromium}/bin/chromium"}
        export PI_LEARN_RSVG=${lib.escapeShellArg "${pkgs.librsvg}/bin/rsvg-convert"}
        export PUPPETEER_SKIP_DOWNLOAD=1
        if [[ -n "''${TMUX:-}" || ! -t 0 || ! -t 1 ]]; then
          exec ${lib.getExe tutor.package} "$@"
        fi
        for arg in "$@"; do
          case "$arg" in
            --help|-h|--version|-v|--print|-p|--mode|--export|install|remove|uninstall|update|list|config)
              exec ${lib.getExe tutor.package} "$@" ;;
          esac
        done
        # Carry the closure and personal config into even an existing tmux
        # server; its environment may predate this launcher.
        cmd="$(printf '%q ' env \
          "PATH=$PATH" \
          "PI_CODING_AGENT_DIR=''${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}" \
          "PI_LEARN_AGENTS_DIR=$PI_LEARN_AGENTS_DIR" \
          "PI_LEARN_PI_BIN=$PI_LEARN_PI_BIN" \
          "PI_LEARN_MMDC=$PI_LEARN_MMDC" \
          "PI_LEARN_CHROMIUM=$PI_LEARN_CHROMIUM" \
          "PI_LEARN_RSVG=$PI_LEARN_RSVG" \
          "PUPPETEER_SKIP_DOWNLOAD=1" \
          ${lib.getExe tutor.package} "$@")"
        tmuxEnv=()
        while IFS= read -r name; do
          case "$name" in
            *_API_KEY|*_AUTH_TOKEN|*_BASE_URL|AWS_*|AZURE_*|GOOGLE_*|ANTHROPIC_OAUTH_TOKEN)
              tmuxEnv+=(-e "$name=''${!name}") ;;
          esac
        done < <(compgen -e)
        exec tmux new-session "''${tmuxEnv[@]}" -c "$PWD" "$cmd"
      '';
    };
in
{
  flake.nixosModules.pi = { pkgs, ... }: {
    imports = [ inputs.pi.nixosModules.default ];
    programs.pi.coding-agent.enable = true;
    environment.systemPackages = [ (mkLearningPackage pkgs) ];
  };

  perSystem = { pkgs, ... }: {
    packages.pi-learn = mkLearningPackage pkgs;
  };
}
