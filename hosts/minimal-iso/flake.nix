{
  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixos-generators, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    in {
      packages = forAllSystems (system: {
        iso = nixos-generators.nixosGenerate {
          inherit system;

          modules = [
            ./configuration.nix
          ];

          customFormats = {
            install-iso-minimal = {
              imports = [
                "${toString nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
              ];
              isoImage.squashfsCompression = "zstd -Xcompression-level 6";
              formatAttr = "isoImage";
            };
          };
          format = "install-iso-minimal";
        };
        do-iso = nixos-generators.nixosGenerate {
          inherit system;

          modules = [
            ./configuration.nix
          ];

          format = "do";
        };
      });
    };
}
