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

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  news.display = "silent";
}
