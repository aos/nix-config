{
  description = "Server nixos configurations";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
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
            nixpkgs.pkgs = import nixpkgs {
              system = defaultSystem;
              config = {
                allowUnfree = true;
                cudaSupport = true;
              };
            };
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
        synth = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/synth ];
          specialArgs = {
            inherit inputs;
          };
        };

        tower = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = pkgsForSystem "x86_64-linux";
          modules = [ ./hosts/tower ];
          specialArgs = {
            inherit inputs;
          };
        };

        thalamus = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = pkgsForSystem "x86_64-linux";
          modules = [ ./hosts/thalamus ];
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

        tao = mkHomeConfiguration {
          system = "x86_64-linux";
          modules = [ ./home/aos/tao.nix ];
        };

        "aos@synth" = mkHomeConfiguration {
          system = "x86_64-linux";
          modules = [ ./home/aos/synth.nix ];
        };

        "aos@tower" = mkHomeConfiguration {
          system = "x86_64-linux";
          modules = [ ./home/aos/tower.nix ];
        };

        "aos@thalamus" = mkHomeConfiguration {
          system = "x86_64-linux";
          modules = [ ./home/aos/thalamus.nix ];
        };
      };

      # Helper script to make updating sops easier
      packages."${defaultSystem}".sops-local =
        pkgs.writeShellScriptBin "sops-local" ''
          export SOPS_AGE_KEY=$(ssh-to-age -private-key -i ~/.ssh/id_tower)
          ${pkgs.lib.getExe pkgs.sops} $@
        '';

      devShells."${defaultSystem}" = {
        default =
          with (pkgsForSystem defaultSystem);
          mkShell {
            buildInputs = [
              self.packages.${system}.sops-local

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
