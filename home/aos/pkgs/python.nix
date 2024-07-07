{ pkgs, ... }:

{
  home.packages = [
    (pkgs.python311.withPackages (
      ps: with ps; [
        pynvim
        python-lsp-server
      ]
    ))
  ];
}
