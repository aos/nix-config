{
  inputs,
  lib,
  ...
}:

{
  imports = [
    inputs.srvos.nixosModules.mixins-systemd-boot
    inputs.srvos.nixosModules.mixins-mdns
    ./hardware-configuration.nix
    ./disko.nix
  ];

  networking.hostName = "temple";

  networking.useDHCP = true;
  systemd.network.enable = true;

  time.timeZone = "America/New_York";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.firewall.allowedTCPPorts = [
    22
    80
    443
  ];

  system.stateVersion = "25.05";
}
