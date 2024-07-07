{
  pkgs,
  configs,
  inputs,
  ...
}:

{
  imports = [
    inputs.disko.nixosModules.disko
    ./nixos/configuration.nix

    ../../modules/nixos/nix.nix
    ../../modules/nixos/system.nix
  ];
}
