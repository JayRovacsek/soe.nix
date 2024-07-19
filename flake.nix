{
  description = "Build nixos or nix-darwin configurations via layers";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        gitignore.follows = "gitignore";
      };
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flake-tests.url = "github:antifuchs/nix-flake-tests";
  };

  outputs = { flake-utils, git-hooks, nixpkgs, nix-flake-tests, self, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        checks = {
          pre-commit = git-hooks.lib.${system}.run {
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

          tests = nix-flake-tests.lib.check {
            inherit pkgs;
            tests = {
              diff = {
                expr = self.lib.diff {
                  foo = "bar";
                  baz = [ "barz" ];
                } {
                  foo = "bar";
                  baz = [ "barz" ];
                  fooz = 1;
                };
                expected = [{ fooz = 1; }];
              };

              no-diff = {
                expr = self.lib.diff {
                  foo = "bar";
                  baz = [ "barz" ];
                } {
                  foo = "bar";
                  baz = [ "barz" ];
                };
                expected = [ ];
              };
            };
          };
        };
        devShells.default = pkgs.mkShell {
          name = "dev-shell";
          packages = with pkgs; [ nixfmt statix vulnix ];
          # Self reference to make the default shell hook that which generates
          # a suitable pre-commit hook installation
          inherit (self.checks.${system}.pre-commit) shellHook;
        };

        formatter = pkgs.nixfmt;
      }) // {
        lib = import ./lib { inherit self; };
      };
}
