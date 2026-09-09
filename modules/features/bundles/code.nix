{ self, ... }:

{
  flake.nixosModules.myCode = {
    imports = [
      self.nixosModules.llm-agents
    ];

    home-manager.sharedModules = [
      self.homeModules.myVscodium
      # self.homeModules.myHelix
    ];

    
  };
}
