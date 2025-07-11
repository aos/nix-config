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

  # sops.defaultSopsFile = lib.mkForce ../../../sops/samira/secrets.enc.yaml;

  networking.hostName = "soraya";

  networking.useDHCP = true;
  systemd.network.enable = true;

  time.timeZone = "America/New_York";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "24.11";
}
