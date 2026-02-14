{ inputs }:
# This is an overlay
final: prev: {
  glowm = prev.callPackage ./glowm {
    mermaidAscii = inputs.mermaid-ascii.packages.${final.system}.default;
  };
}
