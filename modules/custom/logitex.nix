{ ... }:
{
  flake.nixosModules.logitechs =
    { config, lib, ... }:
    let
      cfg = config.my.services.logitechs;
    in
    {
      options.my.services.logitechs.enable =
        lib.mkEnableOption "Logitech wireless device support and the Solaar GUI";

      config = lib.mkIf cfg.enable {
        hardware.logitech.wireless.enable = true;
        programs.solaar.enable = true;
      };
    };
}
