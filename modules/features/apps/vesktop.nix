{
  flake.homeModules.vesktop =
    { pkgs, ... }:
    {
      programs.vesktop = {
        enable = true;

        settings = {
          appBadge = false;
          arRPC = true;
          checkUpdates = false;
          customTitleBar = false;
          disableMinSize = true;
          minimizeToTray = false;
          tray = false;
          splashBackground = "#000000";
          splashColor = "#ffffff";
          splashTheming = true;
          staticTitle = true;
          hardwareAcceleration = true;
          discordBranch = "stable";
        };

        vencord.settings = {
          autoUpdate = false;
          autoUpdateNotification = false;
          disableMinSize = true;
          notifyAboutUpdates = false;
          useQuickCss = true;
          plugins = {

            FakeNitro = {
              enable = true;
            };
            FullSearchContext = {
              enable = true;
            };
          };

        };
      };
    };
}
