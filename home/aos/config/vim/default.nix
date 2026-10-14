{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim
    tree-sitter
    ripgrep
    fd # for Snacks.explorer
  ];
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
