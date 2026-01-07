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

    delta

    zathura
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.gpg.enable = true;
  programs.gpg.publicKeys = [
    {
      source = ../config/gpg-0xFF404ABD083C84EC-2023-09-13.asc;
      trust = 5;
    }
  ];

  xdg = {
    configFile = {
      "kagi/config.json".source = ./kagi_search.json;
      "ghostty/config".source = ./terminal/ghostty;
      "atuin/config.toml".source = ./atuin.toml;
      "zathura/".source = ./zathura;
      "foot/foot.ini".source = ./terminal/foot.ini;
    };
  };

  home.file = {
    ".ssh/id_rsa_yk.pub".source = ./ssh_id_rsa_yk.pub;
    ".ssh/config".source = ./ssh_config;

    ".tmux.conf".source = ./tmux;

    ".gdbinit".source = ./gdbinit;

    ".gitconfig".source = ./gitconfig;
    ".ignore".source = ./rg_ignore;

    ".pi/agent/extensions".source = ./pi-extensions;

    # ".gnupg/gpg-agent.conf".source = ./gpg-agent.conf;
  };

  news.display = "silent";
}
