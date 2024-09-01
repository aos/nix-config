# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./disko-luks-btrfs.nix
  ];

  nixpkgs.config.allowUnfree = true;

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

  # time.timeZone = "America/New_York";
  services.automatic-timezoned.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = false;
  services.xserver.desktopManager.gnome.enable = false;

  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "ctrl:nocaps";

  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
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
    # pinentryPackage = pkgs.pinetry-curses;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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
