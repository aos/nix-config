{ pkgs, ... }:

{
  hardware.enableAllFirmware = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl

    tree
    htop
    unzip
  ];

  programs.git = {
    enable = true;
    prompt.enable = true;
  };
}
