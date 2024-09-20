{ config, lib, pkgs, ... }:
let
  cfg = config.services.livebook-server;
  defaultPort = 8080;
  defaultUser = "livebook";
  defaultGroup = defaultUser;
  defaultDataDir = "/var/lib/livebook";
in
{
  ### Interface
  options = {
    services.livebook-server = {
      enable = lib.mkEnableOption "Service for Livebook";
      enableUserService = lib.mkEnableOption "User service for Livebook";

      package = lib.mkPackageOption pkgs "livebook" { };

      environment = lib.mkOption {
        type = with lib.types; attrsOf (nullOr (oneOf [ bool int str ]));
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
          option, but should instead use
          [](#opt-services.livebook.environmentFile). See the documentation for
          that option for more information.

          Any environment variables specified in the
          [](#opt-services.livebook.environmentFile) will supersede environment
          variables specified in this option.
        '';

        example = lib.literalExpression ''
          {
            LIVEBOOK_PORT = 8080;
          }
        '';
      };

      environmentFile = lib.mkOption {
        type = with lib.types; nullOr lib.types.path;
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
          and the [](#opt-services.livebook.environment) configuration parameter
          for further options.
        '';
        example = "/var/lib/livebook.env";
      };

      extraPackages = lib.mkOption {
        type = with lib.types; listOf package;
        default = [ ];
        example = lib.literalExpression "with pkgs; [ gcc gnumake ]";
        description = ''
          Extra packages to make available to the Livebook service.
        '';
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = defaultUser;
        example = "yourUser";
        description = ''
          The user to run Livebook as.
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

      dataDir = lib.mkOption {
        type = lib.types.path;
        default = defaultDataDir;
        example = "/home/yourUser";
        description = ''
          The home path for the livebook user. Also sets the `LIVEBOOK_HOME`
          environment variable.
        '';
      };

      openDefaultPort = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = ''
          Opens the default Livebook port on TCP and UDP: `8080`.
        '';
      };

      cudaSupport = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = ''
          Enable cuda support for Livebook.
        '';
      };
    };
  };

  ### Implementation
  config = lib.mkIf (cfg.enable || cfg.enableUserService) {
    networking.firewall = lib.mkIf cfg.openDefaultPort {
      allowedTCPPorts = [ defaultPort ];
      allowedUDPPorts = [ defaultPort ];
    };

    users.users = lib.mkIf (cfg.user == defaultUser) {
      ${defaultUser} =
        { 
          group = cfg.group;
          home  = cfg.dataDir;
          createHome = true;
          description = "Livebook daemon user";
          isNormalUser = true;
        };
    };

    users.groups = lib.mkIf (cfg.group == defaultGroup) {
      ${defaultGroup} = { };
    };

    systemd.services.livebook-server = {
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "always";
        EnvironmentFile = cfg.environmentFile;
        ExecStart = "${cfg.package}/bin/livebook start";
        KillMode = "mixed";

        # Fix for the issue described here:
        # https://github.com/livebook-dev/livebook/issues/2691
        #
        # Without this, the livebook service fails to start and gets
        # stuck running a `cat /dev/urandom | tr | fold` pipeline.
        IgnoreSIGPIPE = false;
        DeviceAllow = [
          # CUDA
          "char-nvidiactl"
          "char-nvidia-caps"
          "char-nvidia-frontend"
          "char-nvidia-uvm"
        ];
      };
      environment = lib.mapAttrs (name: value:
        if lib.isBool value then lib.boolToString value else toString value)
        cfg.environment;
      path = [ pkgs.bash ] ++ cfg.extraPackages;
      wantedBy = [ "multi-user.target" ];
    };
  };
}
