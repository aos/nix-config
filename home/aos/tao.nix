{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  home.username = "aos.dabbagh";
  home.homeDirectory = "/home/aos.dabbagh";

  imports = [
    ./pkgs
    ./config
  ];

  home.file.".gitconfig_custom".text = ''
    [user]
    signingkey = ~/.ssh/id_ed25519.pub

    [gpg]
    format = ssh

    [commit]
    gpgsign = true
  '';

  programs.jujutsu.settings.signing = {
    behavior = "own";
    backend = "ssh";
    key = "~/.ssh/id_ed25519.pub";
  };

  home.packages = with pkgs; [
    ansible
    packer
    terraform
    terraform-ls

    gh
    cloudflared

    # Pinned to nixpkgs-stable: google-cloud-sdk 570.0.0 on unstable has a
    # broken bundled-python3 auto-patchelf step (libpython3.14.so.1.0,
    # libtcl9.0.so). Upstream fix: NixOS/nixpkgs#527528.
    (let
      pkgsStable = import inputs.nixpkgs-stable {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    in
    pkgsStable.google-cloud-sdk.withExtraComponents [
      pkgsStable.google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
    awscli2
    ssm-session-manager-plugin

    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.tuicr
  ];
}
