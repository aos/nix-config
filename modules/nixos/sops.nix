{ inputs, lib, ... }:

{
  imports = [ inputs.sops-nix.nixosModules.default ];

  sops.defaultSopsFormat = "yaml";
}
