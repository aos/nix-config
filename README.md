## nix configs

Managing my systems and dotfiles using Nix.

### Installation

1. Set up Yubikey for GPG + SSH
```
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
```
2. Clone repo
3. Set up home-manager
```
nix run home-manager/master -- init
home-manager switch --flake .#aos
```
4. nvim (install plugins)
```
nvim +PlugInstall +PlugClean! +qall
```

### Run

```
home-manager switch --flakes .#aos@tower
```

### Yubikey

1. Import the public key: `gpg --import gpg-public-key-$KEYID.asc`
2. Import trust settings: `gpg --import-ownertrust < gpg-owner-trust.txt`
3. Insert yubikey into USB
4. Import: `gpg --card-status`

### Secrets

```
nix develop
sops sops/general/secrets.enc.yaml
```

> If you want to edit with the SSH host key, you must generate a temporary age secret key
```
SOPS_AGE_KEY=$(ssh-to-age -private-key -i ~/.ssh/id_ed25519) sops sops/general/secrets.enc.yaml
```

### TUI view

```
nix run github:bluskript/nix-inspect -- -p .
```

### Terraform

```
nix develop .#terraform
```
