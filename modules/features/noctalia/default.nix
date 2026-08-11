{ self, inputs, ... }: {
  perSystem = { pkgs, ... }: {

      packages.myNoctalia =
    let
      noctaliaLocation = "/home/monad/.config/noctalia";
    in 
      inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;
        
        outOfStoreConfig = noctaliaLocation;

        autoCopyConfig = true;
        settings =
          (builtins.fromJSON
            (builtins.readFile ./noctalia.json)).settings;
      };
  };
}
