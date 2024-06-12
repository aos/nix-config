{ pkgs, ... }:

pkgs.mkShell {
  buildInputs = [
    pkgs.nixos-anywhere
    pkgs.terraform-ls

    pkgs.sops
    (pkgs.terraform.withPlugins (p: [
      p.hcloud
      p.digitalocean
      p.sops
    ]))
  ];
}
