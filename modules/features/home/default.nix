{ self, ... }:

{
  flake.homeModules.default = {
    imports = [
      # self.homeModules.user
      # self.homeModules.fuzzel
      
      # self.homeModules.thunderbird
      # alacritty
      # yazi

      # etc.
    ];
  };
}
