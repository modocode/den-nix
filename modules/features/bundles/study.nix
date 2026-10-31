{ self, ... }:

{
  flake.nixosModules.study = { pkgs, ... }: {
    imports = [
      # self.nixosModules.anki
    ];
    environment.systemPackages = with pkgs; [
      obsidian
    ];
  };
}
