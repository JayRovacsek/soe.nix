{ self }:
let
  inherit (self.inputs.nixpkgs.lib) nixosSystem;
  inherit (self.inputs.nixpkgs.lib.attrsets) recursiveUpdate filterAttrs;
  inherit (self.inputs.darwin.lib) darwinSystem;
in {
  inherit darwinSystem nixosSystem;
  nixosSoe = nixosSystem;
  darwinSoe = darwinSystem;

  diff = base:
    filterAttrs (name: value:
      # Check if base set has the same property
      if (builtins.hasAttr name base) then
      # If it does and the value is a set, then recurse 
        if builtins.typeOf value == "set"
        && builtins.typeOf (builtins.getAttr name base) == "set" then
          (self.lib.diff value (builtins.getAttr name base)) != { }
        else
        # Check the value for equality
          (builtins.getAttr name base) != value
      else
      # Extended has a value base does not
        true);

  applySoe = { soe, system }:
    let
      options = recursiveUpdate system.options soe.options;
      specialArgs =
        recursiveUpdate system._module.specialArgs soe._module.specialArgs;
      config = recursiveUpdate system.config soe.config;

    in soe.extendModules {
      modules = [{ inherit config options; }];
      inherit specialArgs;
    };
}
