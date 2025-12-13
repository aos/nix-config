{
  description = "Server nixos configurations";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
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
      url = "github:clan-lol/clan-core";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.sops-nix.follows = "sops-nix";
      inputs.disko.follows = "disko";
    };
    colmena.url = "github:zhaofengli/colmena";
    hyprland.url = "github:hyprwm/Hyprland/v0.51.1";
    catppuccin.url = "github:catppuccin/nix";
    niri-flake.url = "github:sodiboo/niri-flake";
    gotoz.url = "git+https://git.sr.ht/~aos/gotoz";
    atools.url = "github:aos/atools";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      clan-core,
      colmena,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      defaultSystem = "x86_64-linux";
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [
            inputs.gotoz.overlays.default
            inputs.atools.overlays.default
          ];
          config.allowUnfree = true;
        };
      defaultPackages = pkgsFor defaultSystem;
      mkHomeConfiguration =
        { system, modules }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor system;
          extraSpecialArgs = {
            inherit inputs outputs;
          };
          inherit modules;
        };

      clan = clan-core.lib.clan {
        meta.name = "floofs";
        directory = ./.;
        specialArgs = {
          inherit inputs;
        };
        machines = {
          samira = {
            nixpkgs.pkgs = defaultPackages;
            imports = [ ./hosts/samira ];
          };

          soraya = {
            nixpkgs.pkgs = defaultPackages;
            imports = [ ./hosts/soraya ];
          };

          sakina = {
            nixpkgs.pkgs = defaultPackages;
            imports = [
              ./hosts/sakina
            ];
          };
        };
      };
    in
    {
      colmenaHive = colmena.lib.makeHive {
        meta = {
          allowApplyAll = false;
          specialArgs = {
            inherit inputs;
          };

          nixpkgs = defaultPackages;

          # special override nixpkgs for some systems
          nodeNixpkgs = {
            biggie = import nixpkgs {
              system = defaultSystem;
              config = {
                allowUnfree = true;
                cudaSupport = true;
                # For weechat-matrix plugin
                permittedInsecurePackages = [
                  "olm-3.2.16"
                ];
              };
            };
          };
        };

        biggie = { ... }: {
          imports = [ ./hosts/biggie ];
        };

        # Home assistant, etc.
        temple = { ... }: {
          imports = [ ./hosts/temple ];
        };

        # VPS
        pylon = { ... }: {
          imports = [ ./hosts/pylon ];
        };
      };

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
          pkgs = pkgsFor "x86_64-linux";
          modules = [ ./hosts/tower ];
          specialArgs = {
            inherit inputs;
          };
        };

        thalamus = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = pkgsFor "x86_64-linux";
          modules = [ ./hosts/thalamus ];
          specialArgs = {
            inherit inputs;
          };
        };
      } // clan.config.nixosConfigurations;

      inherit (clan.config) clanInternals;
      clan = clan.config;

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

        "aos@vm" = mkHomeConfiguration {
          system = "x86_64-linux";
          modules = [ ./home/aos/vm.nix ];
        };
      };

      # Helper script to make updating sops easier
      packages."${defaultSystem}".sops-local =
        with defaultPackages;
        writeShellScriptBin "sops-local" ''
          export SOPS_AGE_KEY=$(ssh-to-age -private-key -i ~/.ssh/id_tower)
          ${lib.getExe pkgs.sops} $@
        '';

      devShells."${defaultSystem}" = {
        default =
          with defaultPackages;
          mkShell {
            buildInputs = [
              self.packages.${defaultSystem}.sops-local

              nixos-anywhere
              inputs.clan-core.packages.${defaultSystem}.clan-cli
              inputs.colmena.packages.${defaultSystem}.colmena

              nix-inspect # Run with: nix-inspect -p .
              sops
              age
              ssh-to-age
              terraform-ls
              (terraform.withPlugins (p: [
                p.hetznercloud_hcloud
                p.digitalocean_digitalocean
                p.carlpett_sops
              ]))
            ];
          };
      };

      formatter."${defaultSystem}" = defaultPackages.nixfmt-rfc-style;
    };
}
