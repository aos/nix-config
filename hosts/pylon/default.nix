{
  pkgs,
  configs,
  inputs,
  ...
}:

{
  imports = [
    ../../modules/nixos/server.nix
    ./nixos/configuration.nix
  ];
}
