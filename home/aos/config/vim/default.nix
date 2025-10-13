{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ neovim ];
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.file = {
    "init.lua" = {
      source = ./vimrc;
      target = ".config/nvim/init.lua";
    };
  };
}
