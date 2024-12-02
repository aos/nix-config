{ ... }:

{
  # Requires something like this for nixpkgs
  # nixpkgs.config.permittedInsecurePackages = [
  #   # required by opentabletdriver
  #   "dotnet-sdk_6"
  # ];
  hardware.opentabletdriver.enable = true;
}
