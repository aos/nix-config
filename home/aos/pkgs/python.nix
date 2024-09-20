{ pkgs, ... }:

let
  llm-claude-3 = pkgs.python3Packages.callPackage ./llm-claude-3.nix { };
in
{
  home.packages = [
    (pkgs.python3.withPackages (
      ps: with ps; [
        pynvim
        python-lsp-server
        llm
        llm-claude-3
      ]
    ))
  ];
}
