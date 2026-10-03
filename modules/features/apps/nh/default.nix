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
