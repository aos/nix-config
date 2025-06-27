{ inputs, pkgs, lib, ... }:

{
  imports = [
    inputs.srvos.nixosModules.hardware-hetzner-cloud
    ./disko.nix
  ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # There's a bug somewhere with this, disable for now
  # We don't plan on increasing the root partition anytime soon
  boot.growPartition = lib.mkForce false;

  networking.hostName = "pylon";
  time.timeZone = "America/New_York";

  networking.firewall.allowedTCPPorts = [
    22
    80
    443
  ];

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4ff:f0:d641::1";

  system.stateVersion = "23.05";
}
