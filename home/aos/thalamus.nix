{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  nixpkgsStable = import inputs.nixpkgs-stable {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (config.nixpkgs) config;
  };
  latestZoom = pkgs.zoom-us.overrideAttrs (final: prev: {
    src = pkgs.fetchurl {
      url = "https://zoom.us/client/6.2.5.2440/zoom_x86_64.pkg.tar.xz";
      hash = "sha256-h+kt+Im0xv1zoLTvE+Ac9sfw1VyoAnvqFThf5/MwjHU=";
    };
  });
  openfortivpn-webview = pkgs.callPackage ./pkgs/openfortivpn-webview.nix { };
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
    slack
    latestZoom
    nixpkgsStable.mypaint

    openfortivpn
    openfortivpn-webview
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  news.display = "silent";
}
