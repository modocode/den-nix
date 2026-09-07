{self, moduleWithSystem, ...}:

{

  flake.nixosModules.scientific = moduleWithSystem({pkgs, ...}:

    {
      environment.systemPackages = [
        pkgs.wxmaxima
        pkgs.octaveFull
        pkgs.gnuplot
      ];

    });

}
