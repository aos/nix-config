{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    wl-clipboard

    fzf
    ripgrep

    gotoz
    atuin
  ];

  programs.fish = {
    enable = true;
    shellAliases = {
      vim = "nvim";
      k = "kubectl";
    };
    shellInit = ''
      fish_config theme choose "Mono Smoke"
    '';
    interactiveShellInit = ''
      ${lib.getExe pkgs.nix-your-shell} fish | source
      ${lib.getExe pkgs.gotoz} --init fish | source
      ${lib.getExe pkgs.fzf} --fish | FZF_CTRL_R_COMMAND= source
      ${lib.getExe pkgs.atuin} init fish --disable-up-arrow | source

      set -U fish_greeting # Disable greeting

      set -x FZF_DEFAULT_OPTS '--height 30% --layout reverse --border --multi'
      set -x FZF_CTRL_T_COMMAND '${lib.getExe pkgs.ripgrep} --files --hidden --follow --no-require-git'

      set -x MANPAGER '${lib.getExe pkgs.neovim} +Man!'
    '';
    functions = {
      qr = "${lib.getExe pkgs.qrencode} -t ansiutf8 ''$argv";
      qq = ''pi --model zai/glm-4.7 -p "''$argv"'';
      t = ''
        if test -z $argv[1]
          set dirname xx
        else
          set dirname $argv[1]
        end
        pushd (mktemp -d -t $dirname.XXXX)
      '';
      untmp = ''
        if test -z $argv[1]
          set base (basename (pwd))
          set untemp_dir ~/scratch/$base
        else
          set untemp_dir $argv[1]
        end
        mkdir -p $untemp_dir
        cp -r * $untemp_dir/ 2>/dev/null; or true
        for f in .*
          if test "$f" != "." -a "$f" != ".."
            cp -r "$f" $untemp_dir/ 2>/dev/null; or true
          end
        end
        pushd $untemp_dir
      '';
    };
  };

  home.file = {
    fish_vcs_prompt = {
      source = ./fish/fish_vcs_prompt.fish;
      target = ".config/fish/functions/fish_vcs_prompt.fish";
    };
    fish_prompt = {
      source = ./fish/fish_prompt.fish;
      target = ".config/fish/functions/fish_prompt.fish";
    };
  };

  ### bash (mainly used to init fish)
  programs.bash = {
    enable = true;
    initExtra = lib.mkBefore ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${lib.getExe pkgs.fish} $LOGIN_OPTION
      fi
    '';
  };

  home.file = {
    bash_aliases = {
      source = ./bash/bash_aliases;
      target = ".bash_aliases";
    };
    bash_functions = {
      source = ./bash/bash_functions;
      target = ".bash_functions";
    };
    inputrc = {
      source = ./inputrc;
      target = ".inputrc";
    };
  };

  targets.genericLinux.enable = true;
}
