{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.srvos.nixosModules.hardware-hetzner-cloud
    ./disko.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "pylon";
  time.timeZone = "America/New_York";

  nixpkgs.hostPlatform = "x86_64-linux";

  users.users.aos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      curl
      vim
      gitMinimal
    ];
    openssh.authorizedKeys.keyFiles = [
      ../../../sops/keys/aos/authorized_keys
    ];
  };

  #systemd.network.networks."10-uplink".networkConfig.Address = "";

  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "24.05";
}
