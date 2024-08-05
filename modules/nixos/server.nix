{ inputs, pkgs, ... }:

{
  imports = [
    inputs.disko.nixosModules.default
    inputs.sops-nix.nixosModules.default
    inputs.srvos.nixosModules.server
  ];

  users.users.root.openssh.authorizedKeys.keyFiles = [ ../../sops/keys/aos/authorized_keys ];
  users.users.mei = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      curl
      vim
      gitMinimal
    ];
    openssh.authorizedKeys.keyFiles = [ ../../sops/keys/aos/authorized_keys ];
  };
}
