{inputs, moduleWithSystem, ...}:

{

  flake.nixosModules.emacs = moduleWithSystem (
    {self', ...}:

    {...}:
      

    {
      services.emacs = {
        enable = true;
			  package = self'.packages.emacs;
        defaultEditor = true;
              
      };

    });


  perSystem = {pkgs,  ...}:{
    packages.emacs = inputs.wrapper-modules.wrappers.emacs.wrap {
      inherit pkgs;
      runtimePkgs = [pkgs.hledger];
      package = pkgs.emacs-pgtk;
      emacsPackages = epkgs:  [
        epkgs.vterm
        epkgs.envrc
      ];

  };

  };

}
