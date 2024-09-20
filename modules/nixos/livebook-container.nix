{ config, lib, pkgs, ... }:
let
  cfg = config.services.livebook-container;
  defaultPorts = [ 8080 8081 ];
in
{
  ### Interface
  options.services.livebook-container = {
    enable = lib.mkEnableOption "Service for Livebook";
    imageName = lib.mkOption {
      type = lib.types.str;
      default = "livebook-dev/livebook";
      example = "livebook-dev/livebook";
      description = ''
        The name of the livebook image.
      '';
    };
    imageTag = lib.mkOption {
      type = lib.types.str;
      default = "latest";
      example = "0.14.2-cuda12";
      description = ''
        The tag for the livebook image.
      '';
    };
    exposeDefaultPorts = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false; 
      description = ''
        Whether to expose port 8080 from the container to the system.
      '';
    };
  };

  ### Implementation
  config = lib.mkIf cfg.enable {
    services.livebook-container = {
      virtualisation.oci-containers.livebook = {
        image = cfg.imageName;
      };
    };
  };
}

# podman run --rm --gpus all \
#            -p 8080:8080 -p 8081:8081 \
#            -e LIVEBOOK_PASSWORD="securesecret" \
#            -v train:/data \
#            ghcr.io/livebook-dev/livebook:0.14.0-cuda12
