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

  programs.jujutsu.settings.signing = {
    sign-all = true;
    backend = "ssh";
    key = "~/.ssh/id_ed25519.pub";
  };

  home.packages = with pkgs; [
    gh
    cloudflared
    (google-cloud-sdk.withExtraComponents
      ([google-cloud-sdk.components.gke-gcloud-auth-plugin]))
  ];
}
