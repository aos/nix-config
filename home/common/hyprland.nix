{ home, ... }:

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
      ".config/swaylock/".source = ./config/swaylock;
      ".config/swayidle/config".source = ./config/swayidle_config;
      ".config/waybar/".source = ./config/waybar;
      ".config/fuzzel/fuzzel.ini".source = ./config/fuzzel.ini;
      ".config/mako/config".source = ./config/mako;
      ".config/swappy/config".source = ./config/swappy;
    };
  };

  # xdg.configFile."hypr/hyprland.conf".text = ''
  # '' + builtins.readFile ./config/hypr/hyprland.conf;

  # xdg.configFile.hypr.source = ./config/hypr;

  xdg.configFile."electron-flags.conf".text = ''
    --enable-features=UseOzonePlatform
    --ozone-platform=wayland
  '';
}
