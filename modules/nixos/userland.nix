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

    mako # notification daemon
    fuzzel # Launcher
    # raffi # fuzzel dmenu launcher
    # TODO: wait until this hits 0.5.1: https://nixpk.gs/pr-tracker.html?pr=342392

    swaylock
    swayidle

    networkmanagerapplet
    pavucontrol
    brightnessctl

    wl-gammarelay-rs
    grim # screenshot
    slurp # select region -> grim "$(slurp)" - | wl-copy
    swappy # grim -g "$(slurp)" - | swappy -f -

    evince # document viewer
    imv # image viewer
    qalculate-gtk # calculator
    nautilus # file viewer
    wl-clipboard
    xwaylandvideobridge # screensharing bridge

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
    config = {
      common = {
        default = [ "hyprland" ];
      };
      hyprland = {
        default = [ "gtk" "hyprland" ];
      };
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland
    ];
    xdgOpenUsePortal = true;
  };

  fonts.packages = with pkgs; [
    cantarell-fonts
    font-awesome
    noto-fonts-emoji
    material-design-icons
    (nerdfonts.override {
      fonts = [
        "Inconsolata"
        "Ubuntu"
        "Noto"
        "CascadiaCode"
      ];
    })
  ];

  security.rtkit.enable = true;
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

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = false;
  services.xserver.desktopManager.gnome.enable = false;

  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "ctrl:nocaps";

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
