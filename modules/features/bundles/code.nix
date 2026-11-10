{ self, ... }:

{
  flake.nixosModules.myCode = {pkgs,...}: {
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
    environment.systemPackages = with pkgs; [
      devenv

    ];


    
    
    home-manager.sharedModules = [
      # self.homeModules.myVscodium
      self.homeModules.myZed
      # self.homeModules.myHelix
    ];

    
  };
}
