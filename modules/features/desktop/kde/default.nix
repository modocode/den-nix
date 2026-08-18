{self, moduleWithSystem, ...}:


{
  flake.nixosModules.kde-plasma = {pkgs, lib, ...}: {


    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.xserver.desktopManager = {
      plasma6 = {
        enable = true;
      };
    };

    services.displayManager.sddm.wayland.enable = true;


    environment.systemPackages = with pkgs; [
      kdePackages.kcalc
      kdePackages.kdeconnect-kde
      kdePackages.filelight
      kdePackages.kdenlive
      kdePackages.yakuake
			ghostty
    ];
  };

    


  


    
}
