{ pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search vim
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    tree
    htop
  ];
}
