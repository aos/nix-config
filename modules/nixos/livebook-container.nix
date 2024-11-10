{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.livebook-container;
  defaultUser = "livebook";
  defaultGroup = defaultUser;
  defaultDataDir = "/var/lib/livebook";
  nvidiaOption = "--device=nvidia.com/gpu=all";
in
{
  ### Interface
  options.services.livebook-container = {
    enable = lib.mkEnableOption "Service for Livebook";

    imageName = lib.mkOption {
      type = lib.types.str;
      default = "ghcr.io/livebook-dev/livebook";
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
        Whether to expose ports 8080, 8081 from the container to the system.
      '';
    };

    environment = lib.mkOption {
      type =
        with lib.types;
        attrsOf (
          nullOr (oneOf [
            bool
            int
            str
          ])
        );
      default = { };
      description = ''
        Environment variables to set.

        Livebook is configured through the use of environment variables. The
        available configuration options can be found in the [Livebook
        documentation](https://hexdocs.pm/livebook/readme.html#environment-variables).

        Note that all environment variables set through this configuration
        parameter will be readable by anyone with access to the host
        machine. Therefore, sensitive information like {env}`LIVEBOOK_PASSWORD`
        or {env}`LIVEBOOK_COOKIE` should never be set using this configuration
        option, but should instead use `environmentFile` instead. See the
        documentation for that option for more information.

        Any environment variables specified in the `environmentFile` will
        supersede environment variables specified in this option.
      '';

      example = lib.literalExpression ''
        {
          LIVEBOOK_PORT = 8080;
        }
      '';
    };

    environmentFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = ''
        Additional environment file as defined in {manpage}`systemd.exec(5)`.

        Secrets like {env}`LIVEBOOK_PASSWORD` (which is used to specify the
        password needed to access the livebook site) or {env}`LIVEBOOK_COOKIE`
        (which is used to specify the
        [cookie](https://www.erlang.org/doc/reference_manual/distributed.html#security)
        used to connect to the running Elixir system) may be passed to the
        service without making them readable to everyone with access to
        systemctl by using this configuration parameter.

        Note that this file needs to be available on the host on which
        `livebook` is running.

        For security purposes, this file should contain at least
        {env}`LIVEBOOK_PASSWORD` or {env}`LIVEBOOK_TOKEN_ENABLED=false`.

        See the [Livebook
        documentation](https://hexdocs.pm/livebook/readme.html#environment-variables)
        and the `environment` configuration parameter for further options.
      '';
      example = "/var/lib/livebook.env";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = defaultDataDir;
      description = ''
        Directory to attach as a volume to the container's /data directory
      '';
      example = "/home/myUser/train";
    };

    nvidiaSupport = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable support for Nvidia container toolkit. This will pass the option:
        `--device=nvidia.com/gpu=all` to the container.
      '';
      example = true;
    };

    extraOptions = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = ''
        Extra options to pass into the container.
      '';
      example = [ "--network=host" ];
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = defaultUser;
      example = "yourUser";
      description = ''
        The user for the data directory.
        By default, a user named `${defaultUser}` will be created whose home
        directory is [dataDir](#opt-services.livebook.dataDir).
      '';
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = defaultGroup;
      example = "yourGroup";
      description = ''
        The group to run Livebook under.
        By default, a group named `${defaultGroup}` will be created.
      '';
    };
  };

  ### Implementation
  config = lib.mkIf cfg.enable {
    users.users = lib.mkIf (cfg.user == defaultUser) {
      ${defaultUser} = {
        group = cfg.group;
        home = cfg.dataDir;
        createHome = true;
        description = "Livebook user";
        isNormalUser = true;
      };
    };

    users.groups = lib.mkIf (cfg.group == defaultGroup) {
      ${defaultGroup} = { };
    };

    assertions = [
      {
        assertion = cfg.nvidiaSupport -> config.hardware.nvidia-container-toolkit.enable;
        message = ''
          Option nvidiaSupport requires `hardware.nvidia-container-toolkit` to be enabled.
        '';
      }
    ];

    virtualisation.oci-containers.containers.livebook = {
      image = "${cfg.imageName}:${cfg.imageTag}";

      ports = lib.mkIf cfg.exposeDefaultPorts [
        "8080:8080"
        "8081:8081"
      ];

      extraOptions =
        lib.filter (o: o != nvidiaOption) cfg.extraOptions
        ++ lib.optional cfg.nvidiaSupport nvidiaOption;

      volumes = [ "${cfg.dataDir}:/data" ];

      environment = lib.mapAttrs (
        name: value: if lib.isBool value then lib.boolToString value else toString value
      ) cfg.environment;

      environmentFiles = lib.mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];
    };
  };
}
