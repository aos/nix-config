{ home, pkgs, ... }:

{
  home = {
    sessionVariables = {
      NIXOS_OZONE_WL = 1;
      MOZ_ENABLE_WAYLAND = 1;
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_DESKTOP = "niri";
      XDG_SESSION_TYPE = "wayland";
    };

    file = {
      ".config/niri/config.kdl".source = ./config/niri_config.kdl;
      ".config/hypr/".source = ./config/hypr;
      ".config/waybar/".source = ./config/waybar;
      ".config/kanshi/config".source = ./config/kanshi;
      ".config/fuzzel/fuzzel.ini".source = ./config/fuzzel.ini;
      ".config/mako/config".source = ./config/mako;
      ".config/swappy/config".source = ./config/swappy;
      ".config/swaylock/config".source = ./config/swaylock;
      ".config/kagi/config.json".source = ./config/kagi_search.json;
    };

    packages = with pkgs; [
      bluetui
      kagi-search
    ];
  };

  services.hypridle.enable = true;
  # services.mako.enable = true;
  programs.swaylock.enable = true;
  # programs.fuzzel.enable = true;
  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };

  xdg.configFile."electron-flags.conf".text = ''
    --enable-features=UseOzonePlatform
    --ozone-platform=wayland
  '';

  xdg.portal = {
    enable = true;
    config = {
      common.default = [ "gtk" "gnome" ];
      niri = {
        default = [ "gtk" "gnome" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
      };
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    xdgOpenUsePortal = true;
  };
}
