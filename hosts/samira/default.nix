{ ... }:

{
  imports = [
    ../../modules/nixos/server.nix
    ../../modules/nixos/sops.nix
    ../../modules/nixos/network.nix

    ./nixos/configuration.nix
  ];
}
