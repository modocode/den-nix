# secrets/secrets.nix
let
  monad = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMmjM5cWmwvRvKIIVfzBNiZj7vqNAivimsnpXq6u2pkZ";
  # nexus = "ssh-ed25519 AAAA...NEXUS-HOST-PUBLIC-KEY...";
  
  systems = [
    # insert ssh-keys for host machines here
  ];
  
  all = [
    monad
    # nexus
  ];
in
{
  "github-token.age".publicKeys = all ++ systems ;
  # "example-password.age".publicKeys = all;
  # "ssh-private-key.age".publicKeys = all;
}
