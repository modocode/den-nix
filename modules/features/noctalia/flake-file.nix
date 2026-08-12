{
  flake-file.inputs = {
    noctalia = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

  };
}
