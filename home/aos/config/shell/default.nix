{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # required for shell initialization
    fzf
    ripgrep
    wl-clipboard

    gotors
    # direnv
    # atuin
  ];

  programs.fish = {
    enable = true;
    shellAliases = {
      vim = "nvim";
    };
    interactiveShellInit = ''
      ${lib.getExe pkgs.nix-your-shell} fish | source
      set -U fish_greeting # Disable greeting
    '';
    functions = {
      qr = "${lib.getExe pkgs.qrencode} -t ansiutf8 ''$argv";
    };
  };

  home.file.".config/fish/functions/fish_vcs_prompt.fish".source = ./fish/fish_vcs_prompt.fish;
  home.file.".config/fish/functions/fish_prompt.fish".source = ./fish/fish_prompt.fish;

  # allow home-manager to manage shell
  programs.bash = {
    enable = true;
    # import my bashrc
    # bashrcExtra = ''
    #   . ${builtins.toString ./bashrc}

    #   # Add goto shortcut
    #   eval "''$(${lib.getExe pkgs.gotors} init)"
    #   # Add direnv
    #   eval "''$(${lib.getExe pkgs.direnv} hook bash)"
    # '';

    initExtra = lib.mkBefore ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  home.file = {
    "bash_aliases" = {
      source = ./bash_aliases;
      target = ".bash_aliases";
    };

    "bash_functions" = {
      source = ./bash_functions;
      target = ".bash_functions";
    };

    "inputrc" = {
      source = ./inputrc;
      target = ".inputrc";
    };
  };

  targets.genericLinux.enable = true;
}
