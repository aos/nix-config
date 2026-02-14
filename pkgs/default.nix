{ inputs }:
# This is an overlay
final: prev: {
  glowm = prev.callPackage ./glowm.nix {
    mermaidAscii = inputs.mermaid-ascii.packages.${final.system}.default;
  };
}
