{
  lib,
  pkgs,
  config,
  ...
}:

{
  networking.nameservers = [
    # "127.0.0.1"
    # "::1"
    "1.1.1.1"
    "1.0.0.1"
    "2606:4700:4700::1111"
  ];

  services.tailscale.enable = true;

  # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.network.wait-online.enable = false;
}
