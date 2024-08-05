{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  };

  environment.systemPackages = with pkgs; [
    exfatprogs

    waybar
    libnotify

    # swww      # Wallpaper daemon
    mako # notification daemon
    fuzzel # Launcher

    swaylock
    swayidle

    networkmanagerapplet
    pavucontrol
    brightnessctl

    wl-gammarelay-rs
    # busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n -500
    # busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n +500
    # busctl --user -- set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q 4000
    # busctl --user -- set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q 6500

    grim # screenshot
    slurp # select region -> grim "$(slurp)" - | wl-copy
    swappy # grim -g "$(slurp)" - | swappy -f -

    evince # document viewer
    imv # image viewer
    qalculate-gtk # calculator
    nautilus # file viewer

    qt5.qtwayland
    qt6.qtwayland
    drm_info
    wlay # graphical output management (maybe replace with kanshi?)

    firefox
  ];

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland
    ];
  };

  fonts.packages = with pkgs; [
    cantarell-fonts
    font-awesome
    noto-fonts-emoji
    (nerdfonts.override {
      fonts = [
        "Inconsolata"
        "Ubuntu"
        "Noto"
      ];
    })
  ];

  security.rtkit.enable = true;

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber = {
      enable = true;
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --asterisks --cmd Hyprland";
      };
    };
  };

  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  # allow automounting USB devices
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
}
