{ config, ... }: {
  services.nix-daemon.enable = true;
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = 4;
}
