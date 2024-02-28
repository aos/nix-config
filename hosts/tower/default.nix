{ pkgs, configs, inputs, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.nixos-hardware.nixosModules.framework-11th-gen-intel

    ./nixos/configuration.nix

    ../../modules/nixos/userland.nix
    ../../modules/nixos/nix.nix
    ../../modules/nixos/system.nix
    ../../modules/nixos/virt.nix
  ];

}
