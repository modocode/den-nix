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

  perSystem = {pkgs, lib, self', ...}:{

    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      
      settings = {
        spawn-at-startup = [
          (lib.getExe self'.packages.myNoctalia)
        ];

        window-rules = [
          {
            geometry-corner-radius = 12;
            clip-to-geometry = true;
            draw-border-with-background = true;
          }

        ];

        input = {
          keyboard = {
            repeat-rate = 50;
            repeat-delay = 250;
            xkb.layout = "us";
          };

          touchpad = {
            tap = { };
            natural-scroll = { };
            accel-profile = "flat";
            scroll-factor = 1.0;

          };

          mouse = {
            accel-profile = "flat";
            scroll-factor = 1.0;
          };


        };

          
        switch-events.lid-close.spawn = [
          "noctalia"
          "msg"
          "session"
          "lock-and-suspend"
        ];
        
        xwayland-satellite = {
          path = lib.getExe pkgs.xwayland-satellite;
        };

        
        binds = {
          "Mod+Return".spawn-sh = lib.getExe pkgs.ghostty;

          "Mod+D".spawn-sh =
                lib.getExe self'.packages.myFuzzel;

          "Mod+S".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";
          
          "Mod+Shift+D".spawn-sh =
            "fd --type f | ${lib.getExe self'.packages.myFuzzel} --dmenu | xargs -r xdg-open";

          
            
    

          # Window management
          "Mod+Q".close-window = { };
          "Mod+F".maximize-column = { };
          "Mod+G".fullscreen-window = { };
          "Mod+Space".toggle-window-floating = { };
          "Mod+Shift+Space".switch-focus-between-floating-and-tiling = {};
          "Mod+C".center-column = { };
          "Mod+Tab".toggle-overview = { };


          # move column 
          "Mod+Shift+H".consume-or-expel-window-left = {};
          "Mod+Shift+L".consume-or-expel-window-right = {};
          "Mod+Shift+K".move-window-up = { };
          "Mod+Shift+J".move-window-down = { };

          

          # focus

          "Mod+H".focus-column-left = { };
          "Mod+L".focus-column-right = { };
          "Mod+K".focus-window-up = { };
          "Mod+J".focus-window-down = { };


          "Mod+U".focus-workspace-down = { };
          "Mod+I".focus-workspace-up = { };
          "Mod+Shift+U".move-window-to-workspace-down = { };
          "Mod+Shift+I".move-window-to-workspace-up = { };

          #volume
          "XF86AudioRaiseVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute".spawn-sh = "noctalia msg volume-mute";

          # Brightness
          "XF86MonBrightnessUp".spawn-sh = "${lib.getExe pkgs.brightnessctl} set +10%";
          "XF86MonBrightnessDown".spawn-sh = "${lib.getExe pkgs.brightnessctl} set 10%-";

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
          gaps = 10;
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
