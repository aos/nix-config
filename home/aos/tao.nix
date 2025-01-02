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
    gh
    cloudflared
    (google-cloud-sdk.withExtraComponents
      ([google-cloud-sdk.components.gke-gcloud-auth-plugin]))
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.gpg.enable = true;
  programs.gpg.publicKeys = [
    { source = ./config/gpg-0xFF404ABD083C84EC-2023-09-13.asc; trust = 5; }
  ];

  news.display = "silent";
}
