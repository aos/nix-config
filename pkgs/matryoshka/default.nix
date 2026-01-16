{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  makeWrapper,
  nodejs,
}:

let
  bin_paths = {
    "rlm" = "dist/index.js";
    "rlm-mcp" = "dist/mcp-server.js";
    "lattice-mcp" = "dist/lattice-mcp-server.js";
    "lattice-repl" = "dist/repl/lattice-repl.js";
    "lattice-pipe" = "dist/tool/adapters/pipe.js";
    "lattice-http" = "dist/tool/adapters/http.js";
  };
in

buildNpmPackage {
  pname = "matryoshka-rlm";
  version = "0.2.6";

  src = fetchFromGitHub {
    owner = "yogthos";
    repo = "Matryoshka";
    rev = "v0.2.6";
    sha256 = "sha256:0v6g907dxmjqmvzk79whxx0v4594vii5l3d10w6m862bx3030ayq";
  };

  npmDepsHash = "sha256-u1pOIz+JX2l9IgOL4msEV9LxK/A8WZU85SKLvBdvZjA=";

  buildInputs = [ nodejs ];

  nativeBuildInputs = [ makeWrapper ];

  makeCacheWritable = true;

  buildPhase = ''
    runHook preBuild
    npm run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/lib/node_modules/matryoshka-rlm

    cp -r dist $out/lib/node_modules/matryoshka-rlm/
    cp -r node_modules $out/lib/node_modules/matryoshka-rlm/
    cp package.json $out/lib/node_modules/matryoshka-rlm/

    # Create wrappers for all binaries
    ${lib.strings.concatMapAttrsStringSep "\n"
      (name: value:
        ''
        makeWrapper ${lib.getExe nodejs} $out/bin/${name} \
          --add-flags "$out/lib/node_modules/matryoshka-rlm/${value}"
        ''
      )
      bin_paths
    }

    runHook postInstall
  '';

  meta = {
    description = "Recursive Language Model - Process documents larger than LLM context windows";
    homepage = "https://github.com/yogthos/Matryoshka";
    license = lib.licenses.mit;
    mainProgram = "rlm";
    maintainers = [ ];
  };
}
