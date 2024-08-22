{ pkgs, ... }:

{
  hardware.enableAllFirmware = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  boot.initrd.systemd.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl

    tree
    htop
    unzip
    gitMinimal
  ];
}
