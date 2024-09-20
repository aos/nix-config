{ pkgs, lib, cudaSupport ? false, ... }:

{
  imports = [
    ./livebook.nix
  ];

  nix.settings = {
    substituters = [
      "https://cuda-maintainers.cachix.org"
    ];
    trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  environment.systemPackages = with pkgs; lib.optionals cudaSupport [
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
    linuxPackages.nvidia_x11
  ];

  services.livebook-server = {
    enable = true;
    openDefaultPort = true;
    extraPackages = with pkgs; [
      gitMinimal
      gcc
      gnumake
      cudaPackages.cudatoolkit
      cudaPackages.cudnn
      cudaPackages.cudart
      linuxPackages.nvidia_x11
    ];
    cudaSupport = true;
    environment = {
      LD_LIBRARY_PATH = "${lib.getLib pkgs.cudaPackages.cudnn}:/run/opengl-driver/lib";
    };
  };
}
