{
  pkgs,
  configs,
  inputs,
  ...
}:

{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.nixos-hardware.nixosModules.framework-11th-gen-intel

    ../../modules/nixos/network.nix
    ../../modules/nixos/nfs.nix
    ../../modules/nixos/nix.nix
    ../../modules/nixos/steam.nix
    ../../modules/nixos/system.nix
    ../../modules/nixos/tablet.nix
    ../../modules/nixos/userland.nix
    ../../modules/nixos/virt.nix
    ../../modules/nixos/sops.nix
    ../../modules/nixos/upgrade-diff.nix

    ./nixos/configuration.nix
  ];

  services.resolved = {
    enable = true;
    fallbackDns = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };
}
