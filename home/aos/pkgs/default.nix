{
  pkgs,
  inputs,
  home,
  ...
}:

let
  llm-pkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    ./python.nix
  ];

  # Packages to install
  home.packages = with pkgs; [
    (pass.withExtensions (ext: with ext; [ pass-otp ]))

    nixfmt 

    fx
    jq
    tealdeer
    curl
    tree
    htop
    age
    _1password-cli

    # Infra tools
    gh
    # ansible
    # packer
    # terraform
    # terraform-ls
    # vagrant


    # k8s
    k9s
    kubectl
    kubernetes-helm

    atools

    # etc
    nb
    yazi

    # llms
    llm-pkgs.claude-code
    llm-pkgs.pi
    # pi stuff
    kagi-search
    browser-tools
    matryoshka-rlm

    qalculate-gtk
    mypaint
    lorien
  ];
}
