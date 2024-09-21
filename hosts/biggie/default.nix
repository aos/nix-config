{ inputs, config, ... }:

{
  imports = [
    inputs.srvos.nixosModules.desktop

    ../../modules/nixos/network.nix

    ../../modules/nixos/virt.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/steam.nix

    # ../../modules/nixos/ml.nix

    ./nixos/configuration.nix
  ];

  virtualisation.oci-containers.containers.livebook = {
    image = "ghcr.io/livebook-dev/livebook:0.13.3-cuda12.1";
    ports = [ "8080:8080" "8081:8081" ];
    extraOptions = [ "--device=nvidia.com/gpu=all" ];
    volumes = [ "/root/test_docker/train:/data" ];
    environment = {
      LIVEBOOK_TOKEN_ENABLED = "false";
    };
  };

  clan.core.networking.targetHost = "root@${config.networking.hostName}.local";
  clan.core.deployment.requireExplicitUpdate = true;
}
