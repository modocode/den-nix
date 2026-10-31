
{inputs, ...}:


{
  flake.nixosModules.fonts = {pkgs, ...}:

    {

      nixpkgs.overlays = [
        inputs.apple-fonts.overlays.default
      ];
      
	    fonts = {
		    enableDefaultPackages = true; 
		    packages = with pkgs; [
			    nerd-fonts.fantasque-sans-mono
			    nerd-fonts.jetbrains-mono
			    nerd-fonts.inconsolata
          nerd-fonts.bitstream-vera-sans-mono
          inconsolata
          fira-code
			    ibm-plex
          iosevka-comfy.comfy
          sf-mono-nerd
			    
		    ];

		    fontconfig = {
			    defaultFonts = {
				    serif = [];
				    sansSerif = [];
				    monospace = [ "fantasque-sans-mono"
                          "jetbrains-mono"
                          "fira-code"
                          "bitstream-vera-sans-mono" ] ;
			    };
		    };
		    fontDir.enable = true;
	    };





};

}
