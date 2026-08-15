{ ... }:

{
  flake.homeModules.thunderbird =
    { ... }:
    {
      programs.thunderbird = {
        enable = true;

        profiles.monad = {
          isDefault = true;

          settings = {
            "mail.tabs.drawInTitlebar" = true;
          };
        };
      };
    };
}
