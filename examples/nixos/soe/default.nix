{ config, pkgs, ... }: {
  networking.useDHCP = true;
  system.stateVersion = "22.11";
}
