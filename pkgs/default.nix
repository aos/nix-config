# This is an overlay
final: prev: {
  kagi-search = final.python3.pkgs.callPackage ./kagi-search { };
  browser-tools = final.callPackage ./browser-tools { };
  matryoshka-rlm = final.callPackage ./matryoshka { };
}
