{inputs, moduleWithSystem, ...}:


{

  flake.nixosModules.nh = moduleWithSystem ({
    pkgs,
    self',
    ...
  }:
    {
      programs.nh = {
        package = self'.packages.nh;
        enable = true;
        flake = "/home/monad/den-nix";
        clean.enable = true;
        clean.extraArgs = "--keep-since 4d --keep 3";
      };

    });



  perSystem = {pkgs, ...}:
    {
      packages.nh = inputs.wrapper-modules.wrappers.nh.wrap {
        inherit pkgs;
        flake = "/home/monad/den-nix";
      };


    };



}
