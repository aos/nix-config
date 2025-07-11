{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-images.url = "github:nix-community/nixos-images";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      nixos-images,
      nixos-generators,
      ...
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    in
    {
      packages = forAllSystems (system: {
        default = nixos-generators.nixosGenerate {
          inherit system;
          modules = [
            nixos-images.nixosModules.image-installer
            ./configuration.nix
          ];
          format = "install-iso";
        };
        do-iso = nixos-generators.nixosGenerate {
          inherit system;

          modules = [ ./configuration.nix ];

          format = "do";
        };
      });
    };
}
