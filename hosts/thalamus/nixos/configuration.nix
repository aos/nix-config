{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-luks-btrfs.nix
  ];

  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.loader.efi.canTouchEfiVariables = true;
  services.fstrim = {
    enable = true;
    interval = "weekly"; # default
  };

  networking.hostName = "thalamus";
  networking.networkmanager.enable = true;

  # time.timeZone = "America/New_York";
  services.automatic-timezoned.enable = true;

  # services.printing.enable = true;
  services.libinput = {
    enable = true;
    touchpad.tapping = false;
  };

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

    openssh.authorizedKeys.keyFiles = [
      ../../../sops/keys/aos/authorized_keys
    ];
  };

  users.users.root.openssh.authorizedKeys.keyFiles = [
    ../../../sops/keys/aos/authorized_keys
  ];

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
  system.stateVersion = "24.05"; # Did you read the comment?
}
