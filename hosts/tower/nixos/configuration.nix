{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-luks-btrfs.nix
  ];

  # This is broken
  hardware.framework.enableKmod = false;
  services.hardware.bolt.enable = true;

  sops = {
    age.sshKeyPaths = [ "${config.users.users."aos".home}/.ssh/id_tower" ];
    defaultSopsFile = ../../../sops/general/secrets.enc.yaml;

    secrets.nextdns_config = { };
  };

  services.nextdns = {
    enable = true;
    arguments = [
      "-config-file"
      "${config.sops.secrets."nextdns_config".path}"
    ];
  };

  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.loader.efi.canTouchEfiVariables = true;
  services.fstrim = {
    enable = true;
    interval = "weekly"; # default
  };

  networking.hostName = "tower";
  networking.networkmanager.enable = true;

  # Workaround for https://github.com/NixOS/nixpkgs/issues/476906
  # The wpa_supplicant module adds a resumeCommands that restarts wpa_supplicant
  # after sleep, but this causes a race condition with NetworkManager resulting
  # in a 10-second delay before wifi reconnects.
  powerManagement.resumeCommands = lib.mkForce "";

  # time.timeZone = "America/New_York";
  services.automatic-timezoned.enable = true;

  # services.printing.enable = true;
  services.libinput = {
    enable = true;
    touchpad.tapping = false;
  };

  # Increase the size of the /run/user/<UID>/ directory
  # Defaults to 10% of RAM
  # services.logind.extraConfig = ''
  #   RuntimeDirectorySize=16G
  # '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.aos = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "storage"
      "lp"
      "dialout"
    ];
    packages = with pkgs; [
      vim
      firefox
      git
      home-manager
    ];
  };

  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    settings = {
      default-cache-ttl = 60;
      max-cache-ttl = 120;
    };
    # pinentryPackage = pkgs.pinetry-curses;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
