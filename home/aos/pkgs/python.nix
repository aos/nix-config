{ pkgs, ... }:

let
  llm-anthropic = pkgs.python3Packages.callPackage ./llm-anthropic.nix { };
in
{
  home.packages = [
    (pkgs.python3.withPackages (
      ps: with ps; [
        pynvim
        python-lsp-server
        llm
        llm-anthropic
      ]
    ))
  ];
}
