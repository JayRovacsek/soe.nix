{
  description = "A minimal nixOS SOE flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    soe = {
      url = "github:jayrovacsek/soe.nix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, soe, ... }: {
    soes = {
      "base" = soe.lib.nixosSoe {
        system = "x86_64-linux";
        modules = [ ./base ];
      };
    };

    nixosConfigurations = {
      # This system may represent a user device, the settings of the 
      # above "soe" (base) are applied with priority over this system so that
      # base settings are inherited by this configuration.
      "arcanine" = soe.lib.applySoe {
        soe = self.outputs.soes.base;
        system = soe.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./arcanine ];
        };
      };
    };
  };
}
