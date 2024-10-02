{ self }:
let
  inherit (self.inputs.nixpkgs.lib) nixosSystem;
  inherit (self.inputs.darwin.lib) darwinSystem;
in {
  inherit darwinSystem nixosSystem;

  applySoe = { soe, system }: system.extendModules soe;
}
