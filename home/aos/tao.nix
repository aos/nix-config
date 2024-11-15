{ pkgs, ... }:

{
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  home.username = "aos.dabbagh";
  home.homeDirectory = "/home/aos.dabbagh";

  imports = [
    ./pkgs
    ./config
  ];

  home.file.".gitconfig_custom".text = ''
    [user]
    signingkey = ~/.ssh/id_ed25519.pub

    [gpg]
    format = ssh

    [commit]
    gpgsign = true
  '';

  home.packages = with pkgs; [
    cloudflared
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  news.display = "silent";
}
