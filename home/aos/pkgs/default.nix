{
  pkgs,
  inputs,
  home,
  ...
}:

let
in
{
  imports = [
    ./python.nix
    ./elixir.nix
  ];

  # Packages to install
  home.packages = with pkgs; [
    foot
    (pass.withExtensions (ext: with ext; [ pass-otp ]))

    nixfmt-rfc-style

    jless
    jq
    jujutsu
    qrencode
    tealdeer
    tmux
    curl
    tree
    htop
    age
    delta

    # Infra tools
    ansible
    awscli2
    docker-compose
    packer
    terraform
    terraform-ls
    vagrant

    # k8s
    k9s
    kind
    kubectl
    kubernetes-helm

    gotors
    atools

    # etc
    # mypaint
    nb
    zathura
    yazi
  ];
}
