{ config, pkgs, ... }:

{
  # librespot
  services.shairport-sync.enable = true;

  boot.loader = {
    grub.enable = false;

    raspberryPi.enable = true;
    raspberryPi.version = 3;
  };

  boot.kernelPackages = pkgs.linuxPackages_rpi3;

  hardware.deviceTree = {
    enable = true;
    overlays = [
      "${config.boot.kernelPackages.kernel}/dtbs/overlays/hifiberry-dacplus.dtbo"
    ];
  };
}
