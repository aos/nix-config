{
  config,
  pkgs,
  inputs,
  ...
}:

let
  nixpkgsZoom = import inputs.nixpkgs-zoom {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (config.nixpkgs) config;
  };
in
{
  home.stateVersion = "22.05";
  programs.home-manager.enable = true;

  home.username = "aos";
  home.homeDirectory = "/home/aos";

  imports = [
    ./pkgs
    ./config

    ../common/hyprland.nix
    ../common/gtk.nix
  ];

  home.packages = with pkgs; [
    spotify
    webcord
    # zoom-us
    nixpkgsZoom.zoom-us
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  news.display = "silent";
}
