{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
in
{
  home.stateVersion = "22.05";
  programs.home-manager.enable = true;

  home.username = "aos";
  home.homeDirectory = "/home/aos";

  imports = [
    ./pkgs
    ./config

    ../common/userland.nix
    ../common/theme.nix
  ];

  targets.genericLinux.gpu.enable = false;

  home.packages = with pkgs; [
    spotify
    vesktop
    zoom-us
    slack
    libreoffice
    vlc

    # freecad # missing from nixos cache
    prusa-slicer
    betaflight-configurator
    # nixpkgsBfc.betaflight-configurator

    vagrant
  ];

  fonts.fontconfig.enable = true;
}
