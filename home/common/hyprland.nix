{ home, ... }:

{
  home.file = {
    ".config/hypr/".source = ./config/hypr;
    ".config/swaylock/".source = ./config/swaylock;
    ".config/swayidle/config".source = ./config/swayidle_config;
    ".config/waybar/".source = ./config/waybar;
    ".config/fuzzel/fuzzel.ini".source = ./config/fuzzel.ini;
    ".config/mako/config".source = ./config/mako;
  };
}
