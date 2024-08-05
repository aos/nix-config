{ ... }:

{
  imports = [
    ../../modules/nixos/server.nix
    ./nixos/configuration.nix
  ];

  services.tailscale.enable = true;
}
