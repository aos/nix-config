{ pkgs, ... }:

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
