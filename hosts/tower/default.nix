{
  pkgs,
  configs,
  lib,
  inputs,
  ...
}:

let
  hyprlandPkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
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

  services.flatpak.enable = true;
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

  services.udev = {
    # https://community.frame.work/t/how-to-rebind-the-xf86rfkill-f10-media-key/62545/2
    # sudo systemd-hwdb update && sudo udevadm trigger
    extraHwdb = ''
      # Rewrite RFKILL (airplane mode) of the `wireless device` to `prog1`.
      evdev:input:b0018v32ACp0006*
        KEYBOARD_KEY_100c6=prog1
    '';
    # Turn off some things that cause instant wakeup after suspend
    extraRules =
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
  };

  # Fix for broken mesa with Hyprland
  hardware.graphics = {
    package = hyprlandPkgs.mesa;

    enable32Bit = true;
    package32 = hyprlandPkgs.pkgsi686Linux.mesa;
  };
}
