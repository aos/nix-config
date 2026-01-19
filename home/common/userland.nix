{ home, pkgs, ... }:

{
  imports = [
    # ./swayidle.nix
    ./hypridle.nix
  ];

  home = {
    sessionVariables = {
      NIXOS_OZONE_WL = 1;
      MOZ_ENABLE_WAYLAND = 1;
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_DESKTOP = "niri";
      XDG_SESSION_TYPE = "wayland";
    };

    packages = with pkgs; [
      bluetui
    ];
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };

  xdg = {
    configFile = {
      "waybar".source = ./config/waybar;
      "niri/config.kdl".source = ./config/niri_config.kdl;
      "mako/config".source = ./config/mako;
      "fuzzel/fuzzel.ini".source = ./config/fuzzel.ini;
      "raffi/raffi.yaml".source = ./config/raffi.yaml;
      "swappy/config".source = ./config/swappy;
      "kanshi/config".source = ./config/kanshi;
      "sysc.jpg".source = ./config/sysc.jpg;
      "electron-flags.conf".text = ''
        --enable-features=UseOzonePlatform
        --ozone-platform=wayland
      '';
    };

    portal = {
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

    terminal-exec = {
      enable = true;
      settings.default = ["com.mitchellh.ghostty.desktop"];
    };
  };
}
