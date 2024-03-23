{ inputs, ... }:

{
  imports = [
    inputs.nix-gaming.nixosModules.pipewireLowLatency
    ./nixos/configuration.nix

    ../../modules/nixos/nix.nix
  ];
}
