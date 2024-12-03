{ inputs, pkgs, lib, ... }:

{
  imports = [
    inputs.disko.nixosModules.default
    inputs.srvos.nixosModules.server
  ];

  users.users.root.openssh.authorizedKeys.keyFiles = [ ../../sops/keys/aos/authorized_keys ];
  users.users.mei = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keyFiles = [ ../../sops/keys/aos/authorized_keys ];
  };
}
