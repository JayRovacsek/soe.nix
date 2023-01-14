{ config, pkgs, ... }: {
  networking.useDHCP = false;
  system.stateVersion = "22.05";
}
