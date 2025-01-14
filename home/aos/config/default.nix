{ home, ... }:

{
  imports = [
    ./vim
    ./shell
  ];

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Aos Dabbagh";
        email = "25783780+aos@users.noreply.github.com";
      };
      aliases = {
        d = ["diff"];
        l = ["log"];
      };
      ui = {
        pager = "delta";
        default-command = ["log" "-T" "builtin_log_oneline"];

        diff.format = "git";
      };
      template-aliases = {
        "colored(color, txt)" = "surround(raw_escape_sequence('\\x01\\e[' ++ color ++ 'm\\x02'), raw_escape_sequence('\\x01\\e[0m\\x02'), txt)";
        "red(txt)"     = "colored('31', txt)";
        "yellow(txt)"  = "colored('33', txt)";
        "magenta(txt)" = "colored('35', txt)";
        "cyan(txt)"    = "colored('36', txt)";
        "ps1_repo_info" = ''concat(
          yellow("(@"),
          surround(" ", " ", yellow(bookmarks)),
          surround("", " -> ",
            if(!description,  yellow(separate("+",
              parents.map(|c| coalesce(
              c.tags(), c.bookmarks(), c.change_id().shortest())
              ))))),
          if(empty,
            magenta(change_id.shortest()),
            magenta(change_id.shortest() ++ "*")),
          surround(":", "", concat(
            if(divergent, cyan("Y")),
            if(conflict,  red("X")),
          )),
          yellow(")"),
        )'';
      };
    };
  };

  # program configs
  home.file.".ssh/id_rsa_yk.pub".source = ./ssh_id_rsa_yk.pub;
  home.file.".ssh/config".source = ./ssh_config;
  home.file.".gnupg/gpg-agent.conf".source = ./gpg-agent.conf;
  home.file.".gdbinit".source = ./gdbinit;

  home.file.".tmux.conf".source = ./tmux;

  # home.file.".config/jj/config.toml".source = ./jj_config.toml;
  home.file.".gitconfig".source = ./gitconfig;
  home.file.".ignore".source = ./rg_ignore;
  home.file.".config/foot/foot.ini".source = ./terminal/foot.ini;

  home.file.".config/zathura/".source = ./zathura;
}
