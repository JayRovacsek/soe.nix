{ config, pkgs, ... }: {
  networking.useDHCP = true;
  system.stateVersion = "23.05";
}
