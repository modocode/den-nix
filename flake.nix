{
        inputs = {
          nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
          import-tree.url = "github:vic/import-tree";
          
          flake-parts.url = "github:hercules-ci/flake-parts";
          
          systems.url = "github:nix-systems/default";
          devshell.url = "github:numtide/devshell";

          flake-file.url = "github:vic/flake-file";
          
          home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
          };

          wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

          zen-browser = {
            url = "github:youwen5/zen-browser-flake";
            inputs.nixpkgs.follows = "nixpkgs";
          };
          
          noctalia = {
            url = "github:noctalia-dev/noctalia-shell";
            inputs.nixpkgs.follows = "nixpkgs";
          };

          vicinae-extensions = {
            url = "github:vicinaehq/extensions";
            inputs.nixpkgs.follows = "nixpkgs";
          };

          vicinae = {
            url = "github:vicinaehq/vicinae";
          };

          agenix.url = "github:ryantm/agenix";
          
          # llm-agents.url = "github:numtide/llm-agents.nix";
          # takes to long to update; constant compilation
        };
    
        outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
         imports = [
           inputs.flake-parts.flakeModules.modules
           # inputs.flake-parts.homeModules.modules
           inputs.flake-file.flakeModules.default
           inputs.home-manager.flakeModules.home-manager
           # inputs.vicinae.nixosModules.default
           # inputs.vicinae.homeManagerModules.default
           inputs.devshell.flakeModule   
           (inputs.import-tree ./modules) # keep this commented for now
           

         ];



         systems = import inputs.systems;
         
         # Dev shell for editing this config 
         perSystem = {config, pkgs, ... }: {

           devshells.default =  {


             commands = [
               {
                 name = "hello";
                 command = "echo hello";
                 
               }

               {
                 name = "nt";
                 command = "sudo nixos-rebuild test --flake .#nexus";
               }
               {
                 name = "ns";
                 command = "sudo nixos-rebuild switch --flake .#nexus";
               }

             ];

             devshell.packages = with pkgs; [
               nixd                  # language server — go-to-def, completions, diagnostics
               
               nixfmt-rfc-style      # official RFC 166 formatter (replaces nixpkgs-fmt)
               statix                # lints anti-patterns: with pkgs, rec, etc.

               nixfmt-rfc-style      # official RFC 166 formatter (replaces nixpkgs-fmt)
               statix                # lints anti-patterns: with pkgs, rec, etc.
               deadnix               # finds unused let bindings and funurl = "github:BirdeeHub/nix-wrapction args
               
               nix-tree              # interactive browser for the dependency graph
               nvd                   # diff two generations: nvd diff /run/current-system ./result
               nix-diff              # diff two derivations at the .drv level
               
               nixos-rebuild         # explicit in shell so it's always on PATH
               git                   # flake inputs are git-tracked; nix needs it
               jq                    # handy for picking apart nix eval --json output
             ];
           };
           
         };

       };
}
