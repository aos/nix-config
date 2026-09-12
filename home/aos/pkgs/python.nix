{ pkgs, ... }:

{
  home.packages = [
    (pkgs.python3.withPackages (ps: with ps; [ requests ipython ]))
    pkgs.ty
  ];
}
