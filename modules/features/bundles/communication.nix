{ self, ... }:

{
  flake.nixosModules.communication =
    { pkgs, ... }:
    {
      home-manager.sharedModules = [
        self.homeModules.vesktop

      ];
      
      environment.systemPackages = [
        pkgs.karere
        pkgs._64gram
    

      ];
    };
}
