{ self }:
let
  inherit (self.inputs.nixpkgs.lib) nixosSystem;
  inherit (self.inputs.darwin.lib) darwinSystem;
in
{
  inherit nixosSystem darwinSystem;

  applySoe = { soe, system }: system.extendModules soe;
  darwinSoe = darwinSystem;
  nixosSoe = nixosSystem;
}
