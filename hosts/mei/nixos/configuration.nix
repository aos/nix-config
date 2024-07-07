{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  disko.devices = import ./disko-luks-btrfs.nix { disks = [ "/dev/vda" ]; };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Enable initrd SSH to remote unlock LUKS partition
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222;
      authorizedKeys =
        with lib;
        concatLists (
          mapAttrsToList (
            name: user: if elem "wheel" user.extraGroups then user.openssh.authorizedKeys.keys else [ ]
          ) config.users.users
        );
      hostKeys = [ "/boot/host_ed25519_key" ];
    };
    postCommands = ''
      echo 'cryptsetup-askpass' >> /root/.profile
    '';
  };
  networking.hostName = "hypr-mei";
  time.timeZone = "America/New_York";

  users.users.mei = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      curl
      vim
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINFbiIMHZsQkz+LylrrR2L2MvYUilTS5ixlY5ry0/FLe turret"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDN0z34z7ofUOR2fBa+Q89aor1/J91jLhW62EEE+VyxIlV5s4YeVCbjklhvZ4J/Th20Mxm5tnHff4dcbVfmXn3k3MecXKi59C3UoPm85+RbEFgZdhef6kGIeG7VvEHL/XzHABHx1c4VgV+2l4CxDJjs4yc/dsa2vCNQlvOa3fUZpla/62JZFWwFbI+BxHTN2Qvb58ud4jbs6Lu2y6XSDiQpnlCetttQv77OmJVN1IlyzzkEi57YU7PvhjpTmJzPQx/VMwCyJZUvBMwsSHuVfchFDsS7JbeO6SeZgEEakupfFvFDm353b/N2uLJbK7ARMaFKwLsyxE9yrZV4y5X6yhrMbgdiiKLICKhg61YQ7AKUQHKU6cAIsaO2cAoFyemSqmi2mEjfrhvFoKUFywl1RfKD6avaCsJDgHqHfRoupi9WlGs+M8zhD7hMWtScWJ9yyORODwiNFP4zZ+z4meLAcf85GRkjG/AODByNOKPmPu/z2NMoLkHE5CD/XNjLm2Nb8jkNPgwdSxivb62R/WDYntOVox6B2d/pEz77y6HQw9QMCugPgy3Qot18hrB8MxLj1GUSQ0wPo5RqndnOHbDKsXw2utb6sS1vcCjJo6676jfs89lBBNGo3dUUT2hwZc21xSIa60dyGfUtnvjO3vSh83RsiO5hHTeaqcEucs2e+gNQqQ== cardno:000612249481"
    ];
  };

  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  system.stateVersion = "23.05"; # Did you read the comment?
}
