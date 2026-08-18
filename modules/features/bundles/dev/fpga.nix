{self, moduleWithSystem, ...}:

{

  flake.nixosModules.fpga = moduleWithSystem({pkgs, ...}:

    {
      environment.systemPackages = [
        pkgs.yosys
        pkgs.verilator
        pkgs.gtkwave
      ];

    });

}
