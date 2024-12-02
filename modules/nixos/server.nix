{ inputs, pkgs, lib, ... }:

{
  imports = [
    inputs.disko.nixosModules.default
    inputs.srvos.nixosModules.server
  ];

  # Until this goes in: https://git.clan.lol/clan/clan-core/pulls/2528
  systemd.network.networks."99-ethernet-default-dhcp".networkConfig.MulticastDNS = lib.mkForce true;
  systemd.network.networks."99-wireless-client-dhcp".networkConfig.MulticastDNS = lib.mkForce true;

  users.users.root.openssh.authorizedKeys.keyFiles = [ ../../sops/keys/aos/authorized_keys ];
  users.users.mei = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keyFiles = [ ../../sops/keys/aos/authorized_keys ];
  };
}
