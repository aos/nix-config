{ inputs, lib, ... }:

{
  nix = {
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
      auto-optimise-store = lib.mkDefault true;
      experimental-features = [
        "nix-command"
        "flakes"
        # "repl-flake"
      ];

      accept-flake-config = true;
      log-lines = lib.mkDefault 25;

      # Fallback quickly if substituters are not available.
      connect-timeout = 5;

      substituters = [
        "https://cache.nixos.org"
      ];

      trusted-substituters = [
        "https://cache.nixos.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];

      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://cache.numtide.com"
      ];

      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };
    # TODO: +5 modifier doesn't work...
    # See: https://github.com/NixOS/nix/pull/9894
    gc = {
      automatic = true;
      dates = "weekly";
      # Keep the last 30d of generations
      options = "--delete-older-than 30d";
    };

    # https://discourse.nixos.org/t/difference-between-nix-settings-auto-optimise-store-and-nix-optimise-automatic/25350
    optimise.automatic = true;

    # Set up registry from inputs
    # registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
  };
}
