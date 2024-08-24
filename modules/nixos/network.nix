{
  lib,
  pkgs,
  config,
  ...
}:

{
  networking.nameservers = [
    "127.0.0.1"
    "::1"
    "1.1.1.1"
    "2606:4700:4700::1111"
  ];

  services.tailscale.enable = true;
}
