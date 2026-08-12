{ self, ... }:

{
  flake.homeModules.default = {
    imports = [
      self.homeModules.user
      self.homeModules.fuzzel
      # alacritty
      # yazi

      # etc.
    ];
  };
}
