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
    inputs.sops-nix.nixosModules.sops

    ./nixos/configuration.nix

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
  ];

}
