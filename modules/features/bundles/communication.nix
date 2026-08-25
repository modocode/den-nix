{ self, ... }:

{
  flake.nixosModules.communication =
    { pkgs, ... }:
    {
      home-manager.sharedModules = [
        self.homeModules.vesktop

      ];
      
      environment.systemPackages = with pkgs; [
        karere
        64gram
    

      ]
    };
}
