{
  flake.nixosModules.battery = {
    powerManagement.powertop.enable = true;
    services = {
      upower = {
        enable = true;
        usePercentageForPolicy = true;
        percentageLow = 30;
        percentageCritical = 20;
        percentageAction = 5;
      };
      thermald.enable = true;
      power-profiles-daemon.enable = true;
    };
  };
}
