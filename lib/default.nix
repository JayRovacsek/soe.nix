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

  diff = base: extended:
    filterAttrs (name: value:
      # Check if target value has the same property
      if (builtins.hasAttr name extended) then
      # If it does and the value is a set, then recurse 
      # Note that is current would be assuming both values are
      # sets and could fail
        if builtins.typeOf value == "set" then
          builtins.trace "A"
          (self.lib.diff value (builtins.getAttr name extended))
        else
        # Check the value for equality otherwise
        # TODO: handle the fact lists can have sets also
          (builtins.getAttr name extended) == value
      else
      # Extended does not have the value
        false

    ) base;

  applySoe = { system, soe }:
    let
      inherit (soe.pkgs) system;
      base = nixosSystem { inherit system; };
      diff = { };
      updated = recursiveUpdate system soe;
    in { };
}
