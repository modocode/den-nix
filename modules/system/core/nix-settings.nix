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
            experimental-features = [ "nix-command" "flakes" ];
            flake-registry = "";
            nix-path = config.nix.nixPath;
            extra-substituters = [
              "https://vicinae.cachix.org"
              "https://pi.cachix.org"
              "https://nix-community.cachix.org"
            ];
            extra-trusted-public-keys = [
              "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
              "pi.cachix.org-1:lGeoGJaZ5ZDabuRzkcD5EBTNnDM4HJ1vqeOxlWk1Flk="
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            ];
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


      # nixpkgs.config.allowUnfree = true;
      nixpkgs.config = {
        allowBroken = true;
        allowUnfree = true;
        permittedInsecurePackages = [
          "firefox-esr-140-bin-unwrapped-140.17.0esr"];
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
