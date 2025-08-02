{ lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.gamemode ];
  users.groups.gamemode = { };

  programs.steam = {
    package = pkgs.steam.override {
      # Fix time zone in clock
      extraEnv.TZDIR = "/usr/share/zoneinfo";
      # extraBwrapArgs = [ "--unsetenv TZ" ];
    };

    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;

    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
}
