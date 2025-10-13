{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ neovim ];
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.file = {
    "init.lua" = {
      source = ./init.lua;
      target = ".config/nvim/init.lua";
    };
  };
}
