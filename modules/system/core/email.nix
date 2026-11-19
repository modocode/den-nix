{ inputs, moduleWithSystem, ... }:

{

  flake.homeModules.email = {
    # syncronize emails with mbsync

    services.mbsync = {
      enable = true;
      frequency = "*:0/5";
    };


    programs.mbsync.enable = true;
    programs.msmtp.enable = true;
    
    programs.gpg = {
      enable = true;
      mutableKeys = true;
      mutableTrust = true;
    };

    services.gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-curses; 
    };

    
    programs.notmuch = {
      enable = true;
      hooks = {
        preNew = "mbsync --all";
      };
    };

    accounts.email.accounts.personal = {
      primary = true;
      address = "mosesmbogba79@gmail.com";
      userName = "moses mbogba";
      mbsync = {
        enable = true;
        create = "maildir";
      };
    };
  }

  
  flake.nixosModules.email = {

    home-manager.sharedModules = [
      self.homeModules.email
    ];


  }


   
  
}
