{ self, ... }:

{
  flake.nixosModules.anki =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        anki
        anki-sync-server
        ankiAddons = {
          review-heatmap;
          fsrs4anki-helper;
          ajt-card-management;
        };
      ];
    };
}
