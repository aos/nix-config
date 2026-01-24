{ config, ... }:

{
  imports = [
    ./livebook-container.nix
  ];

  services.livebook-container = {
    enable = true;
    imageTag = "0.18.3-cuda12";
    nvidiaSupport = true;
    environment = {
      LIVEBOOK_TOKEN_ENABLED = false;
    };
    extraOptions = [
      "--add-host=postgres:host-gateway"
    ];
  };
}
