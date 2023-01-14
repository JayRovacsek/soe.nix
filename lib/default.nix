{ self }:
let
  inherit (self.inputs.nixpkgs.lib) nixosSystem recursiveUpdate;
  inherit (self.inputs.darwin.lib) darwinSystem;
in {
  inherit darwinSystem nixosSystem;
  nixosSoe = nixosSystem;
  darwinSoe = darwinSystem;
  applySoe = { system, soe }: recursiveUpdate system soe;
}
