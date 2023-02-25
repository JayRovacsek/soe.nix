{ self }:
let
  inherit (self.inputs.nixpkgs.lib) nixosSystem getAttrs;
  inherit (self.inputs.nixpkgs.lib.attrsets)
    recursiveUpdate filterAttrs setAttrByPath;
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
      # Note that is current would be assuming both values are
      # sets and could fail
        if builtins.typeOf value == "set" then
          (self.lib.diff (builtins.getAttr name base) value) != { }
        else
        # Check the value for equality
        # TODO: handle the fact lists can have sets also (or would we expect this behavior?)
          (builtins.getAttr name base) == value
      else
      # Extended has a value base does not
        true);

  applySoe = { system, soe }:
    let
      inherit (soe.pkgs) system;
      base = nixosSystem { inherit system; };
      delta = self.lib.diff base soe;
      updated = recursiveUpdate system delta;
    in updated;
}
