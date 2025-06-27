{
  config,
  pkgs,
  inputs,
  ...
}:

let
  nixpkgsBfc = import inputs.nixpkgs {
    system = "x86_64-linux";
    overlays = [
      (final: prev: {
        nwjs = prev.nwjs.overrideAttrs {
          version = "0.84.0";
          src = prev.fetchurl {
            url = "https://dl.nwjs.io/v0.84.0/nwjs-v0.84.0-linux-x64.tar.gz";
            hash = "sha256-VIygMzCPTKzLr47bG1DYy/zj0OxsjGcms0G1BkI/TEI=";
          };
        };
      })
    ];
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
    nixpkgsBfc.betaflight-configurator
  ];

  fonts.fontconfig.enable = true;
}
