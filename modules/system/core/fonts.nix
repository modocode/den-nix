
{...}:


{
  flake.nixosModules.fonts = {pkgs, ...}:

    {

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
