{ self, ... }:

{
  flake.nixosModules.office-pdf =
    { pkgs, ... }:
    {
      imports = [
        self.nixosModules.zathura
        self.nixosModules.pdfarranger
      ];
    };
}
