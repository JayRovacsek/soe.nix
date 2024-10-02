{ lib, ... }:
{
  networking.useDHCP = lib.mkOverride 0 true;
  system.stateVersion = "23.05";
  boot.loader.grub.device = "/";
  fileSystems."/" = {
    neededForBoot = true;
    device = "/";
  };
}
