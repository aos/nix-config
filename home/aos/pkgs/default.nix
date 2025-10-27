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
  ];

  # Packages to install
  home.packages = with pkgs; [
    (pass.withExtensions (ext: with ext; [ pass-otp ]))

    nixfmt-rfc-style

    jless
    jq
    tealdeer
    curl
    tree
    htop
    age
    _1password-cli

    # Infra tools
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
    # files-to-prompt

    qalculate-gtk
    mypaint
    lorien
  ];
}
