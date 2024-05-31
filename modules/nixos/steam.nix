{ lib, pkgs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    gamescopeSession.enable = true;

    extraCompatPackages = [
      pkgs.proton-ge-bin
    ];
  };
}
