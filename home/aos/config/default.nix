{ home, pkgs, ... }:

{
  imports = [
    ./vim
    ./shell
    ./jujutsu.nix
  ];

  home.packages = with pkgs; [
    tmux
    foot

    fzf
    ripgrep
    delta

    zathura
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.gpg.enable = true;
  programs.gpg.publicKeys = [
    { source = ../config/gpg-0xFF404ABD083C84EC-2023-09-13.asc; trust = 5; }
  ];

  # program configs
  home.file.".ssh/id_rsa_yk.pub".source = ./ssh_id_rsa_yk.pub;
  home.file.".ssh/config".source = ./ssh_config;
  # home.file.".gnupg/gpg-agent.conf".source = ./gpg-agent.conf;
  home.file.".gdbinit".source = ./gdbinit;

  home.file.".tmux.conf".source = ./tmux;

  home.file.".gitconfig".source = ./gitconfig;
  home.file.".ignore".source = ./rg_ignore;
  home.file.".config/foot/foot.ini".source = ./terminal/foot.ini;

  home.file.".config/zathura/".source = ./zathura;

  news.display = "silent";
}
