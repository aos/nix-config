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

### Tower TPM2 migration notes

Current `tower` state:

- boot now unlocks `cryptroot` + `cryptswap` directly by passphrase
- the old `cryptkey -> cryptroot/cryptswap` chain was removed because it broke with systemd stage-1
- `hosts/tower/nixos/disko-luks-btrfs.nix` still formats these volumes as `LUKS1`, which is not the right base for `systemd-cryptenroll`

Proper TPM2 migration on `tower`:

1. Back up first.
   - Keep a working passphrase slot on every encrypted device while migrating.
   - Do **not** remove the passphrase until TPM2 boot works repeatedly.
2. Move `cryptroot` and `cryptswap` to `LUKS2`.
   - `systemd-cryptenroll` is for the systemd/LUKS2 token flow.
   - Recreate/reinstall is safer than in-place conversion.
3. Keep systemd stage-1 enabled and add TPM2 support:
   ```nix
   boot.initrd.systemd.enable = true;
   boot.initrd.systemd.tpm2.enable = true;
   ```
4. Enroll the devices:
   ```bash
   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/disk/by-partlabel/disk-nvme0n1-root
   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/disk/by-partlabel/disk-nvme0n1-swap
   ```
   - `0+7` is the usual choice with Secure Boot.
   - Without Secure Boot, `0` may be more practical.
5. If systemd does not autodetect the token setup, add:
   ```nix
   boot.initrd.luks.devices.cryptroot.crypttabExtraOpts = [ "tpm2-device=auto" ];
   boot.initrd.luks.devices.cryptswap.crypttabExtraOpts = [ "tpm2-device=auto" ];
   ```
6. Rebuild and test multiple cold boots before removing any passphrase slots.
7. Only after TPM2 boot is stable:
   - remove the legacy `cryptkey` partition from the disko layout
   - remove any old passphrase slots you no longer want

Verification:

```bash
sudo cryptsetup luksDump /dev/disk/by-partlabel/disk-nvme0n1-root
sudo cryptsetup luksDump /dev/disk/by-partlabel/disk-nvme0n1-swap
sudo nixos-rebuild boot --flake .#tower
```

### Generating an ISO

```
nix build ./hosts/minimal-iso#iso
```
