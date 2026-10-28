{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    inputs.disko.nixosModules.default
    inputs.srvos.nixosModules.server
  ];

  # srvos uses a dix flag removed in dix 3.
  srvos.update-diff.command = "${lib.getExe pkgs.nvd} --nix-bin-dir=${config.nix.package}/bin diff";

  boot.kernelModules = [ "nvme_tcp" ];

  users.users.root.openssh.authorizedKeys.keyFiles = [ ../../sops/keys/aos/authorized_keys ];
  users.users.mei = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keyFiles = [ ../../sops/keys/aos/authorized_keys ];
  };
}
