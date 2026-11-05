{
  lib,
  fetchFromGitHub,
  python312Packages,
  katago,
  makeDesktopItem,
  copyDesktopItems,
  imagemagick,
  mtdev,
  writableTmpDirAsHomeHook,
}:
let
  pythonPackages = python312Packages;
  pysgf = pythonPackages.callPackage ./pysgf.nix { };
  # KaTrain uses the audio API removed in Kivy's development branch.
  kivy = (pythonPackages.kivy.override { cython = pythonPackages.cython_0; }).overridePythonAttrs {
    version = "2.3.1";
    src = fetchFromGitHub {
      owner = "kivy";
      repo = "kivy";
      tag = "2.3.1";
      hash = "sha256-q8BoF/pUTW2GMKBhNsqWDBto5+nASanWifS9AcNRc8Q=";
    };
    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace-fail "setuptools~=69.2.0" "setuptools" \
        --replace-fail "wheel~=0.44.0" "wheel" \
        --replace-fail "packaging~=24.0" "packaging"
      substituteInPlace kivy/lib/mtdev.py \
        --replace-fail "LoadLibrary('libmtdev.so.1')" "LoadLibrary('${lib.getLib mtdev}/lib/libmtdev.so.1')"
    '';
  };
  # The included transformer model requires KataGo 1.17 or newer.
  engine =
    if lib.versionOlder katago.version "1.17.1" then
      katago.overrideAttrs {
        version = "1.17.1";
        src = fetchFromGitHub {
          owner = "lightvector";
          repo = "KataGo";
          tag = "v1.17.1";
          hash = "sha256-N4NEOxdQXQZPizfm9qqqB2EAtC5JVRsqG1Cvlzk42Fw=";
        };
      }
    else
      katago;
in
pythonPackages.buildPythonApplication {
  pname = "katrain";
  version = "1.20.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sanderland";
    repo = "katrain";
    rev = "f4981cf905cece90085ce4e3967415d0c16d525f";
    hash = "sha256-pvD0k4xAVKJ0oILPBJizJ1jSZESEkeehOGb+Fas9OdI=";
  };

  build-system = [ pythonPackages.hatchling ];
  dependencies = with pythonPackages; [
    certifi
    chardet
    docutils
    ffpyplayer
    kivy
    pysgf
    screeninfo
    urllib3
    websocket-client
  ];

  # pysgf uses the same chardet.detect API provided by nixpkgs' chardet 6.
  pythonRelaxDeps = [ "chardet" ];

  nativeBuildInputs = [
    copyDesktopItems
    imagemagick
    writableTmpDirAsHomeHook
  ];

  postPatch = ''
    rm -f katrain/KataGo/katago katrain/KataGo/katago.exe katrain/KataGo/*.dll
    substituteInPlace katrain/core/engine.py \
      --replace-fail 'exe = "katrain/KataGo/katago"' 'exe = "${lib.getExe engine}"'
  '';

  postInstall = ''
    install -d $out/share/icons/hicolor/256x256/apps
    magick 'katrain/img/icon.ico[0]' -resize 256x256 \
      $out/share/icons/hicolor/256x256/apps/katrain.png
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "katrain";
      desktopName = "KaTrain";
      comment = "Play and review Go games with KataGo";
      exec = "katrain %f";
      icon = "katrain";
      categories = [
        "Game"
        "BoardGame"
      ];
      mimeTypes = [ "application/x-go-sgf" ];
    })
  ];

  nativeCheckInputs = [ pythonPackages.pytestCheckHook ];
  # This test needs an OpenCL device, which is unavailable in the build sandbox.
  disabledTests = [ "test_ai_strategies" ];
  env = {
    KIVY_NO_ARGS = "1";
    KIVY_NO_FILELOG = "1";
  };
  pythonImportsCheck = [
    "katrain.core.engine"
    "katrain.core.remote_engine"
    "katrain.gui.sound"
  ];

  passthru = {
    katago = engine;
    inherit pysgf;
  };

  meta = {
    description = "Go playing and teaching app with KataGo analysis";
    homepage = "https://github.com/sanderland/katrain";
    license = lib.licenses.mit;
    mainProgram = "katrain";
    platforms = [ "x86_64-linux" ];
  };
}
