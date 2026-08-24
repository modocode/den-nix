{ self, inputs, ... }: {
  perSystem = { pkgs, lib, ... }: {

    packages.myNoctalia = pkgs.writeShellApplication {
      name = "noctalia";

      runtimeInputs = [
        pkgs.noctalia
      ];

      text = ''
        export NOCTALIA_CONFIG_DIR="$HOME/den-nix/modules/features/desktop/noctalia"
        exec ${lib.getExe pkgs.noctalia} "$@"
      '';
    };

  };

}
