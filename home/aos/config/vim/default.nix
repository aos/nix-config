{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ neovim ];
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.file = {
    "vimrc" = {
      source = ./vimrc;
      target = ".vimrc";
    };

    "init.vim" = {
      source = ./init.vim;
      target = ".config/nvim/init.vim";
    };
  };
}
