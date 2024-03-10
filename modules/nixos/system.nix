{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim

    wget
    curl

    tree
    htop
    unzip
  ];
}
