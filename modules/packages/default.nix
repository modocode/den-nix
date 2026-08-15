{ ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      packages = {

        # importing custom derivations

        
        # foo = pkgs.callPackage ./foo/package.nix { };
        # bar = pkgs.callPackage ./bar/package.nix { };
        # baz = pkgs.callPackage ./baz/package.nix { };
      };
    };
}
