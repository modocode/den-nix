{inputs, moduleWithSystem, ...}:

{

  flake.nixosModules.niri = moduleWithSystem (
    {self', ...}:

    {...}:

    {
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };

      programs.niri = {
        enable = true;
        package = self'.packages.myNiri;

      };
      

    });

  perSystem = {pkgs, lib,  ...}:{

    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      
      settings = {
        xwayland-satellite = {
          path = lib.getExe pkgs.xwayland-satellite;
        };

        
        binds = {
          "Mod+Return".spawn-sh = lib.getExe pkgs.alacritty;





          # Window management
          "Mod+Q".close-window = { };
          "Mod+F".maximize-column = { };
          "Mod+G".fullscreen-window = { };
          "Mod+Shift+F".toggle-window-floating = { };
          "Mod+C".center-column = { };


          
          # workspace
          "Mod+1".focus-workspace = "w0";
          "Mod+2".focus-workspace = "w1";
          "Mod+3".focus-workspace = "w2";
          "Mod+4".focus-workspace = "w3";
          "Mod+5".focus-workspace = "w4";
          "Mod+6".focus-workspace = "w5";
          "Mod+7".focus-workspace = "w6";
          "Mod+8".focus-workspace = "w7";
          "Mod+9".focus-workspace = "w8";
          "Mod+0".focus-workspace = "w9";

          # move column 
          "Mod+Shift+H".move-column-left = { };
          "Mod+Shift+L".move-column-right = { };
          "Mod+Shift+K".move-window-up = { };
          "Mod+Shift+J".move-window-down = { };

          

          # focus

          "Mod+H".focus-column-left = { };
          "Mod+L".focus-column-right = { };
          "Mod+K".focus-window-up = { };
          "Mod+J".focus-window-down = { };


          # move to workspace

          "Mod+Shift+1".move-column-to-workspace = "w0";
          "Mod+Shift+2".move-column-to-workspace = "w1";
          "Mod+Shift+3".move-column-to-workspace = "w2";
          "Mod+Shift+4".move-column-to-workspace = "w3";
          "Mod+Shift+5".move-column-to-workspace = "w4";
          "Mod+Shift+6".move-column-to-workspace = "w5";
          "Mod+Shift+7".move-column-to-workspace = "w6";
          "Mod+Shift+8".move-column-to-workspace = "w7";
          "Mod+Shift+9".move-column-to-workspace = "w8";
          "Mod+Shift+0".move-column-to-workspace = "w9";


          #volume
          "XF86AudioRaiseVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";

          # column with
          "Mod+Ctrl+H".set-column-width = "-5%";
          "Mod+Ctrl+L".set-column-width = "+5%";
          "Mod+Ctrl+J".set-window-height = "-5%";
          "Mod+Ctrl+K".set-window-height = "+5%";



          # screenshotting
          "Mod+Shift+S".spawn-sh = lib.getExe (pkgs.writeShellApplication {
            name = "screenshot";
            text = ''
              ${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp} -w 0)" - \
              | ${pkgs.wl-clipboard}/bin/wl-copy
            '';
          });

          ## Editing screenshot
          "Mod+Shift+E".spawn-sh = ''${lib.getExe pkgs.wl-clipboard}/bin/wl-paste | ${lib.getExe pkgs.swappy} -f -'';


          
        };

        layout = {
          gaps = 5;
          focus-ring = {
            width = 3;
            active-color = "#f5c2e7";
            inactive-color = "#313244";
            

          };
        };

       

      };


    };



  };

}
