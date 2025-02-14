{
  pkgs,
  configs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.nixos-hardware.nixosModules.framework-11th-gen-intel

    ../../modules/nixos/network.nix
    ../../modules/nixos/nix.nix
    ../../modules/nixos/steam.nix
    ../../modules/nixos/system.nix

    ../../modules/nixos/userland.nix
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/virt.nix
    ../../modules/nixos/sops.nix
    ../../modules/nixos/upgrade-diff.nix

    ../../modules/nixos/nfs.nix

    ./nixos/configuration.nix
  ];

  programs.fish.enable = true;

  floofs.nfs.enable = true;

  services.tailscale.extraSetFlags = [ "--accept-routes" ];

  services.resolved = {
    enable = true;
    fallbackDns = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };

  services.fwupd.enable = true;

  networking.extraHosts = ''
    127.0.0.1 conduit.example
    127.0.0.1 test.conduit.example
  '';

  # Turn off some things that cause instant wakeup after suspend
  services.udev.extraRules =
    let
      devs = [
        {
          vendor = "0x8086";
          device = "0xa0ed";
        }
        {
          vendor = "0x8086";
          device = "0x9a13";
        }
      ];
    in
    lib.concatStringsSep "\n" (
      map (devs: ''
        # Turn off wakeup for some devices that causes poor suspend behavior
        ACTION=="add" SUBSYSTEM=="pci" ATTR{vendor}=="${devs.vendor}" ATTR{device}=="${devs.device}" ATTR{power/wakeup}="disabled"
      '') devs
    );
}
