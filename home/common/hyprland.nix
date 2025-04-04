{ home, pkgs, ... }:

{
  home = {
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      GDK_BACKEND = "wayland,x11";
    };

    file = {
      ".config/hypr/".source = ./config/hypr;
      ".config/waybar/".source = ./config/waybar;
      ".config/fuzzel/fuzzel.ini".source = ./config/fuzzel.ini;
      ".config/mako/config".source = ./config/mako;
      ".config/swappy/config".source = ./config/swappy;
    };
  };

  services.hypridle.enable = true;
}
