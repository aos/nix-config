{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    curl

    tree
    htop
    unzip
    gitMinimal
  ];
}
