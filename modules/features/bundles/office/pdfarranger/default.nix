{ self, ... }:

{
  flake.nixosModules.pdfarranger =
    { pkgs, ... }:
    {
      enviornment.systemPackages  = [
        pkgs.pdfarranger
      ];
    };
}
