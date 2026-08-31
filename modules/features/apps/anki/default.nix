{ self, ... }:

{
  flake.nixosModules.anki =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        anki
        anki-sync-server
        (anki.withAddons [
          ankiAddons.passfail2
          ankiAddons.review-heatmap
          ankiAddons.fsrs4anki-helper
          ankiAddons.ajt-card-management
        ])

        
      ];
    };
}
