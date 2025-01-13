# https://github.com/NixOS/nixpkgs/pull/373495
{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  llm,
  anthropic,
  pytestCheckHook,
  pytest-asyncio,
  pytest-recording,
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "llm-anthropic";
  version = "0.11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-anthropic";
    tag = version;
    hash = "sha256-dwUTXonVlZyRVEErqQ+LLBTDy0NGHQLaciZOaVi5zBk=";
  };

  build-system = [
    setuptools
    llm
  ];
  dependencies = [ anthropic ];

  # Otherwise tests will fail to create directory
  # Permission denied: '/homeless-shelter'
  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-recording
  ];

  pythonImportsCheck = [ "llm_anthropic" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "LLM access to models by Anthropic, including the Claude series";
    homepage = "https://github.com/simonw/llm-anthropic";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ aos ];
  };
}
