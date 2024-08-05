{
  inputs,
  pkgs,
  configs,
  ...
}:

{
  imports = [
    inputs.disko.nixosModules.default
    inputs.sops-nix.nixosModules.default
    inputs.srvos.nixosModules.server
  ];

  users.users.root.openssh.authorizedKeys.keyFiles = [ ../../sops/keys/aos/authorized_keys ];
}
