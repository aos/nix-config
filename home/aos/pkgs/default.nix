{ pkgs, inputs, home, ... }:

{
  imports = [
    ./python.nix
  ];

  # Packages to install
  home.packages = with pkgs; [
    foot
    (pass.withExtensions (ext: with ext; [ pass-otp ]))

    nixpkgs-fmt

    jless
    jq
    qrencode
    tealdeer
    tmux
    curl
    tree
    htop
    age

    # Infra tools
    ansible
    awscli2
    docker-compose
    packer
    terraform
    vagrant

    # k8s
    k9s
    kind
    kubectl
    kubernetes-helm

    inputs.gotors.packages.${pkgs.system}.default
    inputs.atools.packages.${pkgs.system}.default

    # etc
    mypaint
    nb
    zathura
    yazi
    libreoffice
  ];
}
