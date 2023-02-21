{ self, system }:
let
  name = "dev-shell";
  pkgs = self.inputs.nixpkgs.legacyPackages.${system};
in {
  "${name}" = pkgs.mkShell {
    packages = with pkgs; [ nixfmt statix vulnix nil ];
    # Self reference to make the default shell hook that which generates
    # a suitable pre-commit hook installation
    inherit (self.checks.${system}.pre-commit) shellHook;
  };
  default = self.outputs.devShells.${system}.${name};
}
