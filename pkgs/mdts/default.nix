{
  lib,
  buildNpmPackage,
  fetchzip,
}:
buildNpmPackage rec {
  pname = "mdts";
  version = "0.16.1";

  src = fetchzip {
    url = "https://registry.npmjs.org/mdts/-/mdts-${version}.tgz";
    hash = "sha256-Lb3rP1RMq+K6LEKhb6WlmXD/dCXKLvrMsv0FE0L1MlY=";
  };

  npmDepsHash = "sha256-zJOc5oKox6IE5ED606yenr9nZxSHST2MteW0tlTcaW0=";

  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  npmInstallFlags = [ "--omit=dev" ];
  dontNpmBuild = true;

  meta = {
    description = "A markdown preview server";
    homepage = "https://github.com/unhappychoice/mdts";
    license = lib.licenses.mit;
    mainProgram = "mdts";
    platforms = lib.platforms.all;
  };
}
