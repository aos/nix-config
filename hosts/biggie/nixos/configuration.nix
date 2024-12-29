{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  fileSystems."/data" = {
    options = [ "defaults" "pquota" ];
    device = "/dev/disk/by-partlabel/disk-secondary_hdd-root";
    fsType = "xfs";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.extraModprobeConfig = ''
    options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
  '';

  networking.hostName = "biggie";
  users.users.root.openssh.authorizedKeys.keyFiles = [ ../../../sops/keys/aos/authorized_keys ];

  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";

  environment.systemPackages = with pkgs; [
    jq
    unzip
    vim
    xfsprogs
  ];

  i18n.defaultLocale = "en_US.UTF-8";

  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;

    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };
  };

  services.printing.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.aos = {
    isNormalUser = true;
    description = "aos";
    extraGroups = [
      "networkmanager"
      "wheel"
      "gamemode"
    ];
    packages = with pkgs; [
      firefox
      vim
      curl
      git

      webcord
    ];
  };

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
