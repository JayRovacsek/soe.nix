{ self, system }:
let pkgs = self.inputs.nixpkgs.legacyPackages.${system};
in {
  pre-commit = self.inputs.pre-commit-hooks.lib.${system}.run {
    src = self;
    hooks = {
      nixfmt.enable = true;
      statix.enable = false;
      prettier-write = {
        enable = true;
        name = "Prettier Write";
        entry = "${pkgs.nodePackages.prettier}/bin/prettier --write .";
        files = "\\.(js|ts|jsx|tsx|json|yml|yaml)$";
        language = "system";
      };

      statix-write = {
        enable = true;
        name = "Statix Write";
        entry = "${pkgs.statix}/bin/statix fix";
        language = "system";
        pass_filenames = false;
      };
    };
  };
}
