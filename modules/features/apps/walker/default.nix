{inputs, ...}:

{
  flake.homeModules.walker = {...}: {
    imports = [inputs.walker.homeManagerModules.default];

    programs.walker = {
      enable = true;
      runAsService = true;

      config = {
        providers.prefixes = [
          {provider = "websearch"; prefix = "+";}
          {provider = "providerlist"; prefix = "_";}
        ];
        keybinds.quick_activate = ["F1" "F2" "F3"];
      };
    };

    programs.elephant = {
      enable = true;
      installService = true;
      providers = [
        "desktopapplications"
        "calc"
        "emojis"
        "files"
        "runner"
        "websearch"
        "providerlist"
      ];
    };
  };
}
