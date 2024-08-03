{ lib, pkgs, config, ... }:

{
  sops.templates."nextdns_config".content = ''
    profile ${config.sops.placeholder.nextdns_id}
    report-client-info true
    detect-captive-portals true
  '';

  services.nextdns = {
    enable = true;
    arguments = [
      "-config-file"
      "${config.sops.templates."nextdns_config".path}"
    ];
  };

  networking.nameservers = [
    "127.0.0.1"
    "::1"
  ];
}
