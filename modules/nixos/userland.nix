{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  programs.niri = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    exfatprogs

    # waybar # replaced by service in home-manager
    kanshi # autorandr for wayland
    libnotify

    mako # notification daemon
    fuzzel # Launcher
    # raffi # fuzzel dmenu launcher
    # TODO: wait until this hits 0.5.1: https://nixpk.gs/pr-tracker.html?pr=342392

    # swaylock # in home-manager - programs.swaylock.enable
    # hypridle # in home-manager - services.hypridle

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
    xwayland-satellite

    qt5.qtwayland
    qt6.qtwayland
    drm_info
    xdg-utils

    firefox
    foot
    ghostty
  ];

  xdg = {
    autostart.enable = lib.mkDefault true;
    menus.enable = lib.mkDefault true;
    mime.enable = lib.mkDefault true;
    icons.enable = lib.mkDefault true;
  };

  services.gnome.gnome-keyring.enable = true;

  systemd.user.services.niri-flake-polkit = {
    description = "PolicyKit Authentication Agent provided by niri-flake";
    wantedBy = [ "niri.service" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  fonts.packages = with pkgs; [
    cantarell-fonts
    font-awesome
    dejavu_fonts
    noto-fonts-color-emoji
    material-design-icons
    nerd-fonts.ubuntu
    nerd-fonts.noto
    nerd-fonts.caskaydia-mono
    nerd-fonts.inconsolata
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  services.xserver.enable = true;
  services.displayManager.gdm.enable = false;
  services.desktopManager.gnome.enable = false;

  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "ctrl:nocaps";

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --cmd 'niri-session'";
      };
    };
  };

  security.polkit.enable = true;
  security.rtkit.enable = true;
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
