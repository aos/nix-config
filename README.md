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
home-manager switch --flake .#aos@tower
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
SOPS_AGE_KEY=$(ssh-to-age -private-key -i ~/.ssh/id_tower) sops sops/general/secrets.enc.yaml
```

There is a `sops-local` action that does that above simply.

When generating a new host, grab the SSH pub key from `/etc/ssh/ssh_host_key*` and add that to the `.sops.yaml` via:
```
ssh-to-age -i <pub_key_file>
```

If this host needs access to the **general** secrets, you need to ensure to add that host to the `.sops.yaml` and
update the keys:
```
sops-local updatekeys sops/general/secrets.enc.yaml
```

### TUI view

```
nix develop
nix-inspect -p .
```

### Deploy

```
nixos-rebuild --flake .#pylon --target-host <host> switch
```

### Generating an ISO

```
nix build ./hosts/minimal-iso#iso
```
