{ lib, pkgs, config, ... }:

{
  services.nextdns = {
    enable = true;
    arguments = [
      "-config-file"
      "${config.sops.secrets."nextdns_config".path}"
    ];
  };

  networking.nameservers = [
    "127.0.0.1"
    "::1"
    "1.1.1.1"
    "2606:4700:4700::1111"
  ];
}
