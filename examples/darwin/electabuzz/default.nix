{ config, pkgs, ... }: {
  services.nix-daemon.enable = false;
  nixpkgs.config.allowUnfree = false;
  system.stateVersion = 3;
}
