{ self, ... }:

{
  flake.nixosModules.myCode = {
    imports = [
      # self.nixosModules.llm-agents
      self.nixosModules.tmux
    ];

    programs.direnv = {
      enable = true;

      nix-direnv = {
        enable = true;
      };
    };

    
    
    home-manager.sharedModules = [
      # self.homeModules.myVscodium
      self.homeModules.myZed
      # self.homeModules.myHelix
    ];

    
  };
}
