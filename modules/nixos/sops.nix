{ config, ... }:

{
  sops.defaultSopsFile = ../../sops/general/secrets.enc.yaml;
  sops.defaultSopsFormat = "yaml";

  # Some defaults
  sops.secrets.nextdns_id = {};
}
