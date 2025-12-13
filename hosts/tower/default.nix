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

  services.flatpak.enable = false;
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
        ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
        # Wally flashing rules for Ergodox EZ
        ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
        KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"
      '';
  };
}
