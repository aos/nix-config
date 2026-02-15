{ inputs }:
# This is an overlay
final: prev: {
  glowm = prev.callPackage ./glowm {
    mermaidAscii = inputs.mermaid-ascii.packages.${final.stdenv.hostPlatform.system}.default;
  };
}
