{ 
  pkgs,
  inputs,
  home,
  ...
}:

{
  home.stateVersion = "22.05";
  programs.home-manager.enable = true;

  home.username = "aos.dabbagh";
  home.homeDirectory = "/home/aos.dabbagh";

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  imports = [
    ./config/vim
    ./config/jujutsu.nix
  ];

  home.packages = with pkgs; [
    tmux
    fzf
    ripgrep
    delta

    jless
    jq
    tealdeer
    curl
    tree
    htop
    age

    # k8s
    k9s
    kubectl
    kubernetes-helm

    atools
    yazi

    # llms
    files-to-prompt
  ];

  home.file.".tmux.conf".source = ./config/tmux;

  home.file.".gitconfig".source = ./config/gitconfig;
  home.file.".ignore".source = ./config/rg_ignore;

  news.display = "silent";
}
