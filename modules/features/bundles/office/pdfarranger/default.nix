{ self, ... }:

{
  flake.nixosModules.pdfarranger =
    { pkgs, ... }:
    {
      environment.systemPackages  = [
        pkgs.pdfarranger
      ];
    };
}
