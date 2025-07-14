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

  programs.localsend.enable = true;

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

  services.fwupd = {
    enable = false;
    extraRemotes = [ "lvfs-testing" ];
    uefiCapsuleSettings = {
      DisableCapsuleUpdateOnDisk = true;
    };
  };

  # Turn off some things that cause instant wakeup after suspend
  services.udev.extraRules =
    let
      devs = [
        # USB ports (xHCI)
        # {
        #   vendor = "0x8086";
        #   device = "0xa0ed";
        # }
        # Thunderbolt 4 USB
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
    ) + ''
      # DFU (Internal bootloader for STM32 and AT32 MCUs)
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2e3c", ATTRS{idProduct}=="df11", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", TAG+="uaccess"
    '';
}
