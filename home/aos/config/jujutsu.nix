{ config, pkg, lib, ... }:

let
  fishEnabled = config.programs.fish.enable;
  repoPromptFish = ''concat(
    " (@ ",
    surround("", " ", bookmarks),
    surround("", " -> ",
      if(!description,  separate("+",
        parents.map(|c| coalesce(
        c.tags(), c.bookmarks(), c.change_id().shortest())
        )))),
    if(empty,
      change_id.shortest(),
      change_id.shortest() ++ "*"),
    surround(":", "", concat(
      if(divergent, "Y"),
      if(conflict,  "X"),
    )),
    ")",
  )'';
in
{
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
        lr = ["log -r .."]; # all visible commits in repo
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
        "ps1_repo_info" = if fishEnabled then repoPromptFish else ''concat(
          yellow("(@ "),
          surround("", " ", yellow(bookmarks)),
          surround("", " -> ",
            if(!description,  magenta(separate("+",
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
}
