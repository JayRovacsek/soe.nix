{
  description = "A minimal Darwin SOE flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:lnl7/nix-darwin/master";
    };

    soe = {
      url = "github:jayrovacsek/soe.nix/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "darwin";
      };
    };
  };

  outputs = { self, darwin, nixpkgs, soe }: {
    darwinConfigurations."soe" = darwin.lib.darwinSystem {
      system = "x86_64-darwin";
      modules = [ ./soe ];
    };

    # This system may represent a user device, the settings of the 
    # above "soe" are applied with priority over this system so that
    # base settings are inherited by this configuration.
    darwinConfigurations."electabuzz" = darwin.lib.darwinSystem {
      system = "x86_64-darwin";
      modules = [ ./electabuzz ];
    };
  };
}
