{ self, system }:
let
  pkgs = self.inputs.nixpkgs.legacyPackages.${system};

  checks = {
    pre-commit = self.inputs.pre-commit-hooks.lib.${system}.run
      (import ./pre-commit.nix { inherit self pkgs system; });
  };
in checks
