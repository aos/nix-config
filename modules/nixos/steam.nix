{ lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.gamemode ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;

    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
}
