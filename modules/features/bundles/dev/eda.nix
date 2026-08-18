{self, moduleWithSystem, ...}:

{

  flake.nixosModules.eda = moduleWithSystem({pkgs, ...}:

    {
      environment.systemPackages = [
        pkgs.kicad
        pkgs.ngspice
      ];

    });

}
