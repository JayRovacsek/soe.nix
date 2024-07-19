{ pkgs, ... }: {
  networking.useDHCP = false;
  environment.systemPackages = with pkgs; [ git ];
}
