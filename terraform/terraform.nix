{ pkgs, ... }:

pkgs.mkShell {
  buildInputs = [
    pkgs.sops
    (pkgs.terraform.withPlugins (p: [
      p.digitalocean
      p.sops
    ]))
  ];
}
