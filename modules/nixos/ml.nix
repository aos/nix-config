{ config, ... }:

{
  imports = [
    ./livebook-container.nix
  ];

  services.livebook-container = {
    enable = true;
    imageTag = "0.13.3-cuda12.1";
    nvidiaSupport = true;
    environment = {
      LIVEBOOK_TOKEN_ENABLED = false;
    };
  };
}
