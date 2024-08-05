{
  inputs,
  pkgs,
  configs,
  ...
}:

{
  imports = [
    ../../modules/nixos/server.nix
    ./nixos/configuration.nix
  ];
}
