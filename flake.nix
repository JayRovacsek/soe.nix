{
  description = "Build nixos or nix-darwin configurations via layers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-22.11";

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        nixpkgs-stable.follows = "nixpkgs-stable";
        gitignore.follows = "gitignore";
      };
    };
  };

  outputs = { self, flake-utils, ... }:
    let inherit (flake-utils.lib) allSystems;
    in flake-utils.lib.eachSystem allSystems (system: {
      checks = import ./checks { inherit self system; };
      devShells = import ./devShells { inherit self system; };
      formatter = import ./formatter { inherit self system; };
    }) // {
      lib = import ./lib { inherit self; };
    };
}
