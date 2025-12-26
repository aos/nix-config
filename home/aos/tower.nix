{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  llm-pkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
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

    ../common/userland.nix
    ../common/theme.nix
  ];

  targets.genericLinux.gpu.enable = false;

  home.packages = with pkgs; [
    spotify
    # vesktop # https://nixpkgs-tracker.ocfox.me/?pr=476347
    discord
    zoom-us
    slack
    libreoffice
    vlc

    # freecad # missing from nixos cache
    prusa-slicer
    betaflight-configurator
    # nixpkgsBfc.betaflight-configurator

    # (llm.withPlugins {
    #   llm-anthropic = true;
    # })
    # claude-code
    llm-pkgs.claude-code
    llm-pkgs.pi
    llm-pkgs.beads

    vagrant
  ];

  fonts.fontconfig.enable = true;
}
