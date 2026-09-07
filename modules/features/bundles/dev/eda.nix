{self, moduleWithSystem, ...}:

{

  flake.nixosModules.eda = moduleWithSystem({pkgs, ...}:

    {
      environment.systemPackages = [
        pkgs.kicad
        pkgs.ngspice
        pkgs.qucs-s
        pkgs.qucsator-rf
      ];

    });

}
