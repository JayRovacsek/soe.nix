{ self }:
let inherit (self.inputs.nixpkgs.lib) recursiveUpdate;
in {
  # TODO: validate if system.toplevel.build is borked via this or
  # if this will actually behave how we expect
  applySoe = soe: system: recursiveUpdate system soe;
}
