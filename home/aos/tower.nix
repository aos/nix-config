{
  config,
  pkgs,
  inputs,
  ...
}:
{
  home.stateVersion = "22.05";
  programs.home-manager.enable = true;

  home.username = "aos";
  home.homeDirectory = "/home/aos";

  imports = [
    ./pkgs
    ./config

    ../common/hyprland.nix
    ../common/theme.nix
  ];

  home.packages = with pkgs; [
    spotify
    discord
    zoom-us
    slack
    libreoffice
    vlc
    claude-code
  ];

  fonts.fontconfig.enable = true;
}
