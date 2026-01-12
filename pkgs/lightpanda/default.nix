{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "0.2.0";

  platforms = {
    x86_64-linux = {
      name = "x86_64-linux";
      hash = "sha256-zi99MoHShO5k9yISqv1fWEp0WFwunPf1NQufQa22Ax4=";
    };
  };

  platform = platforms.${stdenv.hostPlatform.system} or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "lightpanda";
  inherit version;

  src = fetchurl {
    url = "https://github.com/lightpanda-io/browser/releases/download/v${version}/lightpanda-${platform.name}";
    inherit (platform) hash;
  };

  dontUnpack = true;

  nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook ];

  installPhase = ''
    mkdir -p $out/bin
    install -m755 $src $out/bin/lightpanda
  '';

  meta = {
    description = "Browser automation tools using Lightpanda headless browser";
    homepage = "https://lightpanda.io";
    license = lib.licenses.asl20;
    platforms = lib.attrNames platforms;
    mainProgram = "lightpanda";
  };
}
