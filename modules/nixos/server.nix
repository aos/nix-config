{
  pkgs,
  configs,
  inputs,
  ...
}:

{
  imports = [
    inputs.disko.nixosModules.default
    inputs.sops-nix.nixosModules.default
    inputs.srvos.nixosModules.server

    ../../modules/nixos/nix.nix
    ../../modules/nixos/system.nix
  ];

  users.users.root.openssh.authorizedKeys.keyFiles = [
    ../../sops/keys/aos/authorized_keys
  ];
}
