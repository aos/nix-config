{ inputs, pkgs, ... }:

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

  networking.hostName = "pylon";
  time.timeZone = "America/New_York";

  nixpkgs.hostPlatform = "x86_64-linux";

  users.users.aos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      curl
      vim
      gitMinimal
    ];
    openssh.authorizedKeys.keyFiles = [ ../../../sops/keys/aos/authorized_keys ];
  };

  networking.firewall.allowedTCPPorts = [ 22 80 443 ];

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4ff:f0:d641::1";

  system.stateVersion = "23.05";
}
