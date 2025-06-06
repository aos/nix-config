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

      log-lines = lib.mkDefault 25;

      # Fallback quickly if substituters are not available.
      connect-timeout = 5;

      substituters = [
        "https://hyprland.cachix.org"
        "https://cache.nixos.org?priority=10"
        "https://nix-community.cachix.org"
      ];

      trusted-substituters = [
        "https://hyprland.cachix.org"
        "https://cache.nixos.org?priority=10"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="

        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
    # TODO: can't really use this as the +5 modifier doesn't work...
    # See: https://github.com/NixOS/nix/pull/9894
    # gc = {
    #   automatic = true;
    #   dates = "weekly";
    #   # Keep the last 5 generations
    #   options = "--delete-older-than +5";
    # };

    # https://discourse.nixos.org/t/difference-between-nix-settings-auto-optimise-store-and-nix-optimise-automatic/25350
    optimise.automatic = true;

    # Set up registry from inputs
    # registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
  };
}
