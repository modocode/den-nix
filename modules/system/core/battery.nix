{
  flake.nixosModules.battery = {
    powerManagement.powertop.enable = true;
    services = {
      upower = {
        enable = true;
        usePercentageForPolicy = true;
        percentageLow = 40;
        percentageCritical = 30;
        percentageAction = 20;
        criticalPowerAction = "PowerOff";
      };
      thermald.enable = true;
      power-profiles-daemon.enable = true;
    };
  };
}
