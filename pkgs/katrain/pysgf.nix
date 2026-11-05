{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  chardet,
  pytestCheckHook,
}:
buildPythonPackage (finalAttrs: {
  pname = "pysgf";
  version = "1.0.0";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-aSQxSaksP9oy0/hO30fwFx5dd0eNTyOX/vOA4dHAn6w=";
  };

  build-system = [ hatchling ];
  dependencies = [ chardet ];
  nativeCheckInputs = [ pytestCheckHook ];
  pythonImportsCheck = [ "pysgf" ];

  meta = {
    description = "Parser for Go game records in SGF, NGF, and GIB formats";
    homepage = "https://github.com/sanderland/pysgf";
    license = lib.licenses.mit;
  };
})
