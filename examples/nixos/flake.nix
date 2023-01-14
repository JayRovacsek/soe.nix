{
  description = "A minimal nixOS SOE flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    soe.url = "github:jayrovacsek/soe.nix/main";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations."soe" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./soe ];
    };

    # This system may represent a user device, the settings of the 
    # above "soe" are applied with priority over this system so that
    # base settings are inherited by this configuration.
    nixosConfigurations."arcanine" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./arcanine ];
    };
  };
}
