{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.aos.fish;
in {
  options.aos.fish.enable = mkEnableOption "fish config";

  config = mkIf cfg.enable {
    programs.fish.enable = true;

    home.packages = with pkgs; [
      fzf
      ripgrep
      wl-clipboard
    ];

    home.file = {
      ".config/fish/functions/fish_greeting.fish".text = ''
        function fish_greeting;end
      '';

      ".config/fish/functions/fish_prompt.fish".source = ./fish_prompt.fish;
      ".config/fish/functions/extras.fish".source = ./extra_functions.fish;
    };

    programs.fish.shellAliases = {
      vim = "nvim";
    };
  };
}
