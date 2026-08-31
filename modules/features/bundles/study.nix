{ self, ... }:

{
  flake.nixosModules.study = {
    imports = [
      self.nixosModules.anki
    ];
  };
}
