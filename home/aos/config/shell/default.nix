{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    wl-clipboard

    gotoz
    # atuin
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

      set -U fish_greeting # Disable greeting

      set -g FZF_DEFAULT_OPTS '--height 30% --layout reverse --border --multi'
      set -g FZF_DEFAULT_COMMAND '${lib.getExe pkgs.ripgrep} --files --hidden --follow --no-require-git'
      set -g FZF_CTRL_T_COMMAND "''$FZF_DEFAULT_COMMAND"
    '';
    functions = {
      qr = "${lib.getExe pkgs.qrencode} -t ansiutf8 ''$argv";
      qq = ''llm -t q "''$argv"'';
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
          set untemp_dir "~/scratch/$base"
        else
          set untemp_dir $argv[1]
        end
        mkdir "$untemp_dir"
        cp (pwd)/* "$untemp_dir"
        cd "$untemp_dir"
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
