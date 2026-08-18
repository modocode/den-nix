{self, moduleWithSystem, ...}:

{

  flake.nixosModules.scientific = moduleWithSystem({pkgs, ...}:

    {
      environment.systemPackages = [
        pkgs.mxmaxima
        pkgs.octave
        pkgs.gnuplot
      ];

    });

}
