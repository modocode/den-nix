{inputs, ...}:

{
  perSystem = {system, ...}: {
    _module.args.unfreePkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  };



  flake.nixosModules.nix = {config, lib, pkgs,  ...}:
    {
      nix = let
        flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
        in 
        {
          settings = {
            experimental-features = "nix-command flakes";
            flake-registry = "";
            nix-path = config.nix.nixPath;
          };
          registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
          nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
           optimise.automatic = true;
           gc = {
             automatic = true;
             dates = "daily";
             options = "--delete-older-than 5d";
           };


        };


      nixpkgs = {
        config = {
          allowUnfree = true;
          packageOverrides = pkgs: {
            unstable = import inputs.nixpkgs-unstable {
              config = {
                allowUnfree = true;
              };

            };

          };

        };
      };

      programs = {
        nix-ld = {
          enable = true;
          libraries = with pkgs; [
            util-linux
            stdenv.cc.cc
            zlib
            libusb1
          ];
        };
      };

    };


}
