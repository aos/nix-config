{
  pkgs,
  configs,
  inputs,
  ...
}:

{
  imports = [
    inputs.disko.nixosModules.disko
    # inputs.nixos-hardware.nixosModules.framework-11th-gen-intel

    ../../modules/nixos/network.nix
    ../../modules/nixos/nix.nix
    ../../modules/nixos/system.nix
    ../../modules/nixos/userland.nix
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/virt.nix
    ../../modules/nixos/upgrade-diff.nix

    ./nixos/configuration.nix
  ];

  services.resolved = {
    enable = true;
    fallbackDns = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };

  networking.extraHosts = ''
    127.0.0.1 conduit.example
    127.0.0.1 test.conduit.example
  '';
}
