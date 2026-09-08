{inputs,self, moduleWithSystem, ...}:

{

  flake.nixosModules.niri = moduleWithSystem (
    {self',inputs', ...}:

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
      home-manager.sharedModules = [
        self.homeModules.myVicinae
      ];
      

    });

  perSystem = {pkgs,inputs', lib, self', ...}:{
    packages.myVicinae = inputs'.vicinae.packages.default;
    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      
      settings = {
        spawn-at-startup = [
          (lib.getExe self'.packages.myNoctalia)
          ["${lib.getExe self'.packages.myVicinae}" "server"]
        ];

        # spawn-sh-at-startup = [
        #   "vicinae server"
        # ];

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
          "Mod+Return".spawn-sh = lib.getExe self'.packages.myGhostty;
          "Mod+E".spawn-sh = "${lib.getExe self'.packages.emacs}client -c ";

          # "Mod+D".spawn-sh =
          #       lib.getExe self'.packages.myFuzzel;



          "Mod+Shift+D".spawn-sh =
            "${lib.getExe self'.packages.myVicinae} toggle";
          "Mod+D".spawn-sh =
            "${lib.getExe self'.packages.myVicinae} open";

          "Mod+S".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";


          # file picker
  #         "Mod+Shift+D".spawn-sh = ''
  #         {
  #           ${lib.getExe pkgs.fd} --type f --hidden . "$HOME/Documents"
  #           ${lib.getExe pkgs.fd} --type f --hidden . "$HOME/Downloads"
  #           ${lib.getExe pkgs.fd} --type f --hidden . "$HOME/org"
  #           ${lib.getExe pkgs.fd} --type f --hidden . "$HOME/Pictures"
  #           ${lib.getExe pkgs.fd} --type f --hidden . "$HOME/Videos"
  #           ${lib.getExe pkgs.fd} --type f --hidden . "$HOME/Projects"
  #         } 2>/dev/null |
  #         ${lib.getExe self'.packages.myFuzzel} --dmenu |
  #         while IFS= read -r file; do
  #           [ -n "$file" ] && ${lib.getExe' pkgs.xdg-utils "xdg-open"} "$file"
  #         done
  #       '';


  #       # clipboard
  #       "Mod+V".spawn-sh = ''
  #           ${lib.getExe pkgs.cliphist} list |
  #           ${lib.getExe self'.packages.myFuzzel} --dmenu |
  #           ${lib.getExe pkgs.cliphist} decode |
  #           ${lib.getExe' pkgs.wl-clipboard "wl-copy"}
  #         '';

          
  #         "Mod+Shift+V".spawn-sh = ''
  #             ${lib.getExe pkgs.cliphist} list |
  #             ${lib.getExe self'.packages.myFuzzel} --dmenu |
  #             ${lib.getExe pkgs.cliphist} delete
  #         '';



  #         # Search browser history with Fuzzel
  #         "Mod+B".spawn-sh = ''
  #         ${lib.getExe' pkgs.xdg-utils "xdg-open"} \
  #           "https://www.google.com/search?q=$(
  #             printf "" |
  #             ${lib.getExe self'.packages.myFuzzel} --dmenu --prompt="Search: " |
  #               ${lib.getExe pkgs.jq} -sRr @uri
  #                                  )"
  #         '';

  #         # Power menu
  #         "Mod+Shift+Escape".spawn-sh = ''
  #   choice="$(
  #     printf "Lock\nSuspend\nReboot\nShutdown\nLogout\n" |
  #     ${lib.getExe self'.packages.myFuzzel} --dmenu
  #                                            )"

  #   case "$choice" in
  #     Lock)
  #       ${lib.getExe pkgs.swaylock}
  #       ;;
  #     Suspend)
  #       systemctl suspend
  #       ;;
  #     Reboot)
  #       systemctl reboot
  #       ;;
  #     Shutdown)
  #       systemctl poweroff
  #       ;;
  #     Logout)
  #       niri msg action quit
  #       ;;
  #   esac
  # '';


  # # Process killer
  # "Mod+Ctrl+P".spawn-sh = ''
  #   pid="$(
  #     ${lib.getExe pkgs.procps} -eo pid,comm,%cpu,%mem --sort=-%cpu |
  #     ${lib.getExe self'.packages.myFuzzel} --dmenu |
  #     ${lib.getExe pkgs.gawk} '{print $1}'
  #   )"
  #   [ -n "$pid" ] && kill "$pid"
  # '';

          
  # Window management
  "Mod+Q".close-window = { };
  "Mod+F".maximize-column = { };
  "Mod+G".fullscreen-window = { };
  "Mod+Space".toggle-window-floating = { };
  "Mod+Shift+Space".switch-focus-between-floating-and-tiling = {};
  "Mod+C".center-column = { };
  "Mod+Tab".toggle-overview = { };


  "Mod+Alt+Comma".consume-window-into-column = { };
  "Mod+Alt+Period".expel-window-from-column = { };

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


  "Mod+U".focus-workspace-down = { };
  "Mod+I".focus-workspace-up = { };
  "Mod+Shift+U".move-window-to-workspace-down = { };
  "Mod+Shift+I".move-window-to-workspace-up = { };

  #volume

  "XF86AudioRaiseVolume".spawn-sh =
    "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";

  "XF86AudioLowerVolume".spawn-sh =
    "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";

  "XF86AudioMute".spawn-sh =
    "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

  
  # Brightness
  "XF86MonBrightnessUp".spawn-sh = "${lib.getExe pkgs.brightnessctl} set +10%";
  "XF86MonBrightnessDown".spawn-sh = "${lib.getExe pkgs.brightnessctl} set 10%-";

  # column with
  "Mod+Ctrl+H".set-column-width = "-5%";
  "Mod+Ctrl+L".set-column-width = "+5%";
  "Mod+Ctrl+J".set-window-height = "-5%";
  "Mod+Ctrl+K".set-window-height = "+5%";



  # screenshotting
  "Print".spawn-sh = lib.getExe (pkgs.writeShellApplication {
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
