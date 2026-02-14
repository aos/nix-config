{
  lib,
  stdenvNoCC,
  makeWrapper,
  glow,
  mermaidAscii,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "glowm";
  version = "unstable-2026-02-14";

  src = ./glowm;

  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/glowm
    patchShebangs $out/bin/glowm

    wrapProgram $out/bin/glowm \
      --prefix PATH : ${
        lib.makeBinPath [
          glow
          mermaidAscii
        ]
      }

    runHook postInstall
  '';

  meta = {
    description = "Glow wrapper with Mermaid-to-ASCII rendering";
    license = lib.licenses.unfree;
    mainProgram = "glowm";
    platforms = lib.platforms.all;
  };
})
