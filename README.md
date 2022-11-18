# soe.nix
A Nixos / Darwin wrapper for system configurations that applies a standard operating environment (SOE) approach 
to system management. Note that for the remainder of the readme the concept of a SOE will be 
referenced as a "profile" (except in code examples)

# Purpose
This flake intends to make configuration of systems more approachable by breaking the problem down into
profiles that can be layered to segments. Consider it to be a parallel to the docker layer concept,
but intentionally chaining inputs and therefore making the end result both far more reproducible and
configurable by a consumer.

# Background
This flake assumes a basic understanding of the nix language as well as nixos/nix-darwin.
Consider reading these resources if you haven't already:
* [how nix works](https://nixos.org/guides/how-nix-works.html) - a 10,000 foot view of how nix works
* [nix language basics](https://nixos.org/guides/nix-language.html#reading-nix-language) - basics of the nix language
* [nix-pills](https://nixos.org/guides/nix-pills/) - a high-level coverage of most things nix
* [nix.dev](https://nix.dev/) - further coverage of the how/why/when/what of nix in general across a number of domains
* 

## Theory of Operation
Currently this repo is a stub due to a lack of time to pursuit it further. The main objectives of this
repo are to create a flake that exposes a nixosModule and darwinModule for consumption by anyone.

### Module Framework
The modules exposed by this flake should have an ability to be enabled as well as consumed by a
profile/configuration option. At a very high level I envision this as roughly the below for a consumer:
```nix
{
  description = "NixOS/Darwin Configurations + SOE Definitions";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-22.05";

    soe = {
      url = "github:jayrovacsek/soe.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }:
    let
      inherit (self.inputs) soe nixpkgs darwin;
      defaultNixos = self.outputs.nixosConfigurations.defaultProfile;
      defaultDarwin = self.outputs.darwinConfigurations.defaultProfile;
    in {
      nixosConfigurations = {
        # This configuration is a profile and is intended to set base opinions and
        # settings for a set of machines - the naming is arbitrary and the contents
        # of ./configuration.nix are that of any nixosSystem as per normal
        defaultProfile = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            # System defined in some configuration files
            ./configuration.nix
            soe.nixosModule
            {
              soe = {
                enable = true;
                provider = true;
              };
            }
          ];
        };

        # This configuration is a consumer of a profile, it could present as an end-user
        # who customises any number of things - the profile however should have last 
        # say on the applied settings for a range of values (dependent on profile definition) 
        shinyNewMachine = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            soe.nixosModule
            {
              soe = {
                enable = true;
                consumer = true;
                profile = defaultNixos;
              };
            }
          ];
        };
      };

      darwinConfigurations = {
        # This configuration is a profile and is intended to set base opinions and
        # settings for a set of machines - the naming is arbitrary and the contents
        # of ./configuration.nix are that of any darwinSystem as per normal
        defaultProfile = darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          modules = [
            # System defined in some configuration files
            ./configuration.nix
            soe.darwinModule
            {
              soe = {
                enable = true;
                provider = true;
              };
            }
          ];
        };

        # This configuration is a consumer of a profile, it could present as an end-user
        # who customises any number of things - the profile however should have last 
        # say on the applied settings for a range of values (dependent on profile definition) 
        shinyNewMachine = nixpkgs.lib.nixosSystem {
          system = "x86_64-darwin";
          modules = [
            soe.darwinModule
            {
              soe = {
                enable = true;
                consumer = true;
                profile = defaultDarwin;
              };
            }
          ];
        };
      };
    };
}
```
In the above example we just self reference configurations for the passed profiles in a target/consumer but in a real-world instance of this we could
have a centrally managed and locked-down profile repository in which more stringent controls can be applied and then a consumer inherits all
the settings of the profile but can also build their own customisations on top.

### Anticipated Footguns
A few foot-guns exist in this idea and likely have solves that I am yet to investigate too much, but they are:

#### Configuration Trampling
Significant/key values that should be unique and/or honoured by a system: take an example of system hostname. If the profile
naively recursively replaces values with expected values we might break select configurations. 

Anticipated solves for this might be 
the use of an allowlist of configuration options: such as removing from the profile the applied hostname and/or other significant values. 

### Anticipated Wins
While yet to be planned fully, the above module system allows for some wins in terms of composable configurations. The most exciting idea 
would be for incremental profile layering that enables either differing teams/use-cases (server profiles/CICD etc) or threat based configurations 
(conditional hardening of devices)

For example consider the below example which chains a "base configuration" with a security tooling configuration (possibly useful for a pentester or alike)
```nix
{
  description = "NixOS/Darwin Configurations + SOE Definitions";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-22.05";

    soe = {
      url = "github:jayrovacsek/soe.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }:
    let
      inherit (self.inputs) soe nixpkgs;
      base = self.outputs.nixosConfigurations.baseProfile;
      securityTools = self.outputs.nixosConfigurations.securityToolsProfile;
    in {
      nixosConfigurations = {
        baseProfile = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            # Arbitrary options applied for base settings
            ./configuration.nix
            soe.nixosModule
            {
              soe = {
                enable = true;
                provider = true;
              };
            }
          ];
        };

        securityToolsProfile = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            # Extra settings applied to enable pentesting or alike
            ./configuration.nix
            {
              # The below isn't a working example given pkgs isn't in scope here
              # but intends to show some element of the configuration applied
              # by this layer of profile
              environment.systemPackages = with pkgs; [
                nmap
                exploitdb
                metasploit
                sqlmap
                massscan
              ];
            }
            soe.nixosModule
            {
              soe = {
                enable = true;
                provider = true;
                consumer = true;
                profile = base;
              };
            }
          ];
        };

        # This configuration is a consumer of a profile, it could present as an end-user
        # who customises any number of things - the profile however should have last 
        # say on the applied settings for a range of values (dependent on profile definition) 
        shinyNewMachine = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            soe.nixosModule
            {
              soe = {
                enable = true;
                consumer = true;
                profile = securityTools;
              };
            }
          ];
        };
      };
    };
}
```
