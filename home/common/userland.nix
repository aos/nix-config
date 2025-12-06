{ home, pkgs, ... }:

{
  home = {
    sessionVariables = {
      NIXOS_OZONE_WL = 1;
      WLR_NO_HARDWARE_CURSORS = "1";
      MOZ_ENABLE_WAYLAND = 1;
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_DESKTOP = "Wayland";
      XDG_SESSION_TYPE = "wayland";
      GDK_BACKEND = "wayland,x11";
      QT_QPA_PLATFORM = "wayland;xcb";
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
    };

    packages = with pkgs; [
      bluetui
    ];
  };

  services.hypridle.enable = true;
  programs.swaylock.enable = true;
  programs.waybar.enable = true;

  xdg.configFile."electron-flags.conf".text = ''
    --enable-features=UseOzonePlatform
    --ozone-platform=wayland
  '';
}
