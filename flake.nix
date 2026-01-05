{
  description = "Server nixos configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    colmena.url = "github:zhaofengli/colmena";
    catppuccin.url = "github:catppuccin/nix";
    gotoz.url = "git+https://git.sr.ht/~aos/gotoz";
    atools.url = "github:aos/atools";
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.numtide.com"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
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
            (import ./pkgs)
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

      packages."${defaultSystem}" = with defaultPackages; {
        # Helper script to make updating sops easier
        sops-local = writeShellScriptBin "sops-local" ''
          export SOPS_AGE_KEY=$(ssh-to-age -private-key -i ~/.ssh/id_tower)
          ${lib.getExe pkgs.sops} $@
        '';

        # home-manager switch with nom
        hms = writeShellScriptBin "hms" ''
          name="''${1}"
          ${lib.getExe home-manager.packages.${defaultSystem}.default} switch \
            --log-format internal-json \
            --flake .#"$name" |& ${lib.getExe nix-output-monitor} --json
        '';

        # nixos-rebuild switch with nom
        nrs = writeShellScriptBin "nrs" ''
          name="''${1}"
          sudo nixos-rebuild switch \
            --log-format internal-json \
            --flake .#"$name" |& ${lib.getExe nix-output-monitor} --json
        '';
      };

      devShells."${defaultSystem}" = {
        default =
          with defaultPackages;
          mkShell {
            buildInputs = [
              self.packages.${defaultSystem}.sops-local
              self.packages.${defaultSystem}.hms
              self.packages.${defaultSystem}.nrs

              nixos-anywhere
              inputs.clan-core.packages.${defaultSystem}.clan-cli
              inputs.colmena.packages.${defaultSystem}.colmena

              nix-inspect # Run with: nix-inspect -p .
              nix-output-monitor
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
