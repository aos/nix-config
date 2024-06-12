{
  description = "Server nixos configurations";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:/NixOS/nixos-hardware/master";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland/v0.40.0";
    gotors.url = "github:aos/gotors";
    atools.url = "github:aos/atools";
  };

  outputs = { self, nixpkgs, home-manager, deploy-rs, ... } @ inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      pkgsForSystem = system: import nixpkgs {
        inherit system;
        # overlays = [ inputs.gotors.overlays.default ];
        config.allowUnfree = true;
      };
      mkHomeConfiguration = { system, modules }: home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsForSystem system;
        extraSpecialArgs = { inherit inputs outputs; };
        inherit modules;
      };
    in {
    nixosConfigurations = {
      biggie = nixpkgs.lib.nixosSystem {
	modules = [
	  ./hosts/biggie
	];
	specialArgs = {inherit inputs;};
      };
      mei = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/mei
        ];
        specialArgs = { inherit inputs; };
      };

      synth = nixpkgs.lib.nixosSystem {
	system = "x86_64-linux";
	modules = [
	  ./hosts/synth
	];
	specialArgs = { inherit inputs; };
      };

      tower = nixpkgs.lib.nixosSystem {
	system = "x86_64-linux";
	modules = [
	  ./hosts/tower
	];
	specialArgs = { inherit inputs; };
      };

      # TODO
      # pylon = nixpkgs.lib.nixosSystem {
      #   system = "x86_64-linux";
      #   modules = [
      #   ];
      # };
    };

    homeConfigurations = {
      aos = mkHomeConfiguration {
        system = "x86_64-linux";

        modules = [
          ./home/aos/home.nix
        ];
      };

      "aos@synth" = mkHomeConfiguration {
        system = "x86_64-linux";

        modules = [
          ./home/aos/synth.nix
        ];
      };

      "aos@tower" = mkHomeConfiguration {
        system = "x86_64-linux";

        modules = [
          ./home/aos/tower.nix
        ];
      };

      mei = mkHomeConfiguration {
        system = "x86_64-linux";

        modules = [
          ./home/mei/home.nix
        ];
      };
    };

    deploy.nodes.mei = {
      hostname = "192.168.122.142";
      profiles = {
        system = {
          sshUser = "mei";
          user = "root";
          path = deploy-rs.lib."${system}".activate.nixos self.nixosConfigurations.mei;
        };
        hm = {
          sshUser = "mei";
          user = "mei";
          path = deploy-rs.lib."${system}".activate.home-manager self.homeConfigurations.mei;
        };
      };
    };

    devShells."${system}" = {
      default = with (pkgsForSystem "x86_64-linux"); mkShell {
        buildInputs = [
          deploy-rs.packages."${system}".deploy-rs
          nixos-anywhere
          sops
          terraform-ls
          (terraform.withPlugins (p: [
            p.hcloud
            p.digitalocean
            p.sops
          ]))
        ];
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
