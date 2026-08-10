{inputs, ...}:

{

  flake-file.inputs = {
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };


}
