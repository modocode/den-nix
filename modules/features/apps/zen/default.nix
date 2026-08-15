{ moduleWithSystem, ... }:

{
  flake.nixosModules.zen-browser = moduleWithSystem (
    { inputs', ... }:
    { ... }:
    {
      environment.systemPackages = [
        inputs'.zen-browser.packages.default
      ];
    }
  );
}
