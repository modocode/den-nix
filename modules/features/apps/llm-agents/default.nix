{ self,inputs, ... }:

{
  flake.nixosModules.llm-agents =
    { pkgs, ... }:
    {
      # environment.systemPackages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      #   claude-code
      #   codex
        # ... other tools
  # ];
    };
}
