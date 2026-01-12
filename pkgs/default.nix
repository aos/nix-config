# This is an overlay
final: prev: {
  kagi-search = final.python3.pkgs.callPackage ./kagi-search { };
  lightpanda = final.callPackage ./lightpanda { };
}
