{ inputs, outputs, lib, config, pkgs, ... }:

{
  home.stateVersion = "23.05";
  home = {
    username = "mei";
    homeDirectory = "/home/mei";
  };
  programs.home-manager.enable = true;
  programs.git.enable = true;

  imports = [
    ../common/colors.nix
    ../common/gtk.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      # outputs.overlays.modifications

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.file.".config/hypr/".source = ./config/hypr;
  home.file.".config/swaylock/config".source = ./config/swaylock_config;
  home.file.".config/waybar/".source = ./config/waybar;
}
