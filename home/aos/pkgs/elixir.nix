{ pkgs, ... }:

let
  beamPkgs = with pkgs.beam_minimal; packagesWith interpreters.erlang_27;
in
{
  home.packages = with beamPkgs; [
    erlang
    elixir_1_17
    elixir-ls
  ];
}
