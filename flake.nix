{
  description = "Server nixos configurations";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-zoom.url = "github:NixOS/nixpkgs/06031e8a5d9d5293c725a50acf01242193635022";
    nixos-hardware.url = "github:/NixOS/nixos-hardware/master";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    clan-core = {
      url = "git+https://git.clan.lol/clan/clan-core";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.sops-nix.follows = "sops-nix";
      inputs.disko.follows = "disko";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    catppuccin.url = "github:catppuccin/nix";
    gotors.url = "github:aos/gotors";
    atools.url = "github:aos/atools";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      clan-core,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      defaultSystem = "x86_64-linux";
      pkgsForSystem =
        system:
        import nixpkgs {
          inherit system;
          overlays = [
            inputs.gotors.overlays.default
            inputs.atools.overlays.default
          ];
          config.allowUnfree = true;
        };
      mkHomeConfiguration =
        { system, modules }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsForSystem system;
          extraSpecialArgs = {
            inherit inputs outputs;
          };
          inherit modules;
        };

      clan = clan-core.lib.buildClan {
        meta.name = "floofs";
        directory = ./.;
        specialArgs = {
          inherit inputs;
        };
        machines = {
          samira = {
            nixpkgs.pkgs = pkgsForSystem defaultSystem;
            imports = [ ./hosts/samira ];
          };

          soraya = {
            nixpkgs.pkgs = pkgsForSystem defaultSystem;
            imports = [ ./hosts/soraya ];
          };

          sakina = {
            nixpkgs.pkgs = pkgsForSystem defaultSystem;
            imports = [ ./hosts/sakina ];
          };

          biggie = {
            nixpkgs.pkgs = pkgsForSystem defaultSystem;
            imports = [ ./hosts/biggie ];
          };

          pylon = {
            nixpkgs.pkgs = pkgsForSystem defaultSystem;
            imports = [ ./hosts/pylon ];
          };
        };
      };
    in
    {
      nixosConfigurations = {
        mei = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/mei ];
          specialArgs = {
            inherit inputs;
          };
        };

        synth = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/synth ];
          specialArgs = {
            inherit inputs;
          };
        };

        tower = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/tower ];
          specialArgs = {
            inherit inputs;
          };
        };
      } // clan.nixosConfigurations;

      inherit (clan) clanInternals;

      homeConfigurations = {
        aos = mkHomeConfiguration {
          system = "x86_64-linux";
          modules = [ ./home/aos/home.nix ];
        };

        "aos@synth" = mkHomeConfiguration {
          system = "x86_64-linux";
          modules = [ ./home/aos/synth.nix ];
        };

        "aos@tower" = mkHomeConfiguration {
          system = "x86_64-linux";
          modules = [ ./home/aos/tower.nix ];
        };

        mei = mkHomeConfiguration {
          system = "x86_64-linux";
          modules = [ ./home/mei/home.nix ];
        };
      };

      devShells."${defaultSystem}" = {
        default =
          with (pkgsForSystem defaultSystem);
          mkShell {
            buildInputs = [
              nixos-anywhere
              inputs.clan-core.packages.${defaultSystem}.clan-cli
              nix-inspect # Run with: nix-inspect -p .
              sops
              age
              ssh-to-age
              terraform-ls
              (terraform.withPlugins (p: [
                p.hcloud
                p.digitalocean
                p.sops
              ]))
            ];
          };
      };

      formatter."${defaultSystem}" = (pkgsForSystem defaultSystem).nixfmt-rfc-style;
    };
}
