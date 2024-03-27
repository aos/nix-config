{ inputs, lib, ... }:

{
  nix = {
    settings = {
      trusted-users = [ "root" "@wheel" ];
      auto-optimise-store = lib.mkDefault true;
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      # Keep the last 5 generations
      options = "--delete-older-than 7d";
    };

    # Set up registry from inputs
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
  };

  nixpkgs.config.allowUnfree = true;
}
