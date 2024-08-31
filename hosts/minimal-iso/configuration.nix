{ config, pkgs, ... }:

{
  networking.hostName = "nixos-installer";
  time.timeZone = "America/New_York";

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  users.users.root.openssh.authorizedKeys.keyFiles = [ ../../sops/keys/aos/authorized_keys ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
  ];
}
