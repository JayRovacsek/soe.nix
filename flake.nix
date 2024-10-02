{
  description = "Build nixos or nix-darwin configurations via layers";

  inputs = {
    devshell = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/devshell";
    };

    flake-utils.url = "github:numtide/flake-utils";

    gitignore = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:hercules-ci/gitignore.nix";
    };

    git-hooks = {
      inputs = {
        nixpkgs.follows = "nixpkgs";
        gitignore.follows = "gitignore";
      };
      url = "github:cachix/git-hooks.nix";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:lnl7/nix-darwin";
    };
  };

  outputs =
    {
      devshell,
      flake-utils,
      git-hooks,
      nixpkgs,
      self,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          overlays = [
            devshell.overlays.default
          ];
          inherit system;
        };
      in
      {
        checks = {
          git-hooks = git-hooks.lib.${system}.run {
            src = self;
            hooks = {
              actionlint.enable = true;

              deadnix = {
                enable = true;
                settings.edit = true;
              };

              nixfmt-rfc-style = {
                enable = true;
                settings.width = 80;
              };

              prettier = {
                enable = true;
                settings.write = true;
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
        };

        devShells.default = pkgs.devshell.mkShell {
          devshell.startup.git-hooks.text = self.checks.${system}.git-hooks.shellHook;
          name = "nix-config";
          packages = with pkgs; [
            nixfmt-rfc-style
            statix
            vulnix
            lix
          ];
        };

        formatter = pkgs.nixfmt;
      }
    )
    // {
      lib = import ./lib { inherit self; };
    };
}
