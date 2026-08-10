{self, inputs, ...}:


{

  flake.nixosConfigurations.nexus = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      # Define Modules For User
      nexusConfig
      hostMain


      # dev; git, shell, terminals/editors, engr software
      # creative ; gimp, pdf/image viewer, mp4 player,  
      # simple ; browser and terminal
      # gaming # steam, bottles, prismlauncher, lutris, factorio
      # office; libreoffice, email clients
      # desktop: window/destop manager, fonts, browsers

      
      

      # good
      desktop
      dev



    ];


  };

}
