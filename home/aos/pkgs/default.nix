{
  pkgs,
  inputs,
  home,
  ...
}:

let
  llm-claude-3 = pkgs.python3Packages.callPackage ./llm-claude-3.nix { };
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
    vagrant

    # k8s
    k9s
    kind
    kubectl
    kubernetes-helm

    inputs.gotors.packages.${pkgs.system}.default
    inputs.atools.packages.${pkgs.system}.default

    # etc
    # mypaint
    nb
    zathura
    yazi
    libreoffice
    (llm.withPlugins [ llm-claude-3 ])
  ];
}
