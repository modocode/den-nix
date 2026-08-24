{self, inputs, ...}:

{

  flake.nixosModules.core = {pkgs, lib, ...}:
    let
      modules = with self.nixosModules; [
        nix
        bootloader
        hardware
        printing
        user
        locale
        battery
        home-manager
      ];
    in {
      imports =
        [
        ]
        ++ modules;

      environment.systemPackages = with pkgs; [
        vim
        wget
        zip
        unzip
        hunspell
        hunspellDicts.en-us
        aspell
        aspellDicts.en
        git

      ];

      system.stateVersion = "23.05";
      
    };  

}
