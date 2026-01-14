{
  lib,
  buildNpmPackage,
  makeWrapper,
  chromium,
  rsync,
  nodejs,
}:

buildNpmPackage {
  pname = "browser-tools";
  version = "1.0.0";

  src = ./.;

  npmDepsHash = "sha256-S5dygh7KInjT7z//qLkc8SbiQPF75oevyPPc26MVIF8=";
  dontNpmBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/browser-tools
    cp -r node_modules $out/lib/browser-tools/
    cp package.json $out/lib/browser-tools/
    cp -r scripts $out/lib/browser-tools/

    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs} $out/bin/browser-tools \
      --add-flags "$out/lib/browser-tools/scripts/browser-tools.js" \
      --prefix PATH : ${lib.makeBinPath [ chromium rsync ]}

    runHook postInstall
  '';

  meta = {
    description = "CDP-based browser automation tools for Chrome/Chromium";
    homepage = "https://github.com/mitsuhiko/agent-stuff";
    license = lib.licenses.mit;
    mainProgram = "browser-tools";
  };
}
