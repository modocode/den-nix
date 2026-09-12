# modules/features/secrets/default.nix
{ inputs, ... }:

{
  flake.nixosModules.secrets =
    { config, ... }:
    {
      imports = [
        inputs.agenix.nixosModules.default
      ];
      
      age.secrets = {
        github-token.file =
          inputs.self + "/secrets/github-token.age";

        # example-password.file =
        #   inputs.self + "/secrets/example-password.age";

        # ssh-private-key = {
        #   file = inputs.self + "/secrets/ssh-private-key.age";
        #   owner = "monad";
        #   mode = "0600";
        # };
      };
    };
}
