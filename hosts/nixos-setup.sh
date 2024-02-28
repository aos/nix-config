#!/usr/bin/env bash
set -euo pipefail

ssh_port="22"
flake=""
luks_disk_key_path=""
disko_script=""
nixos_system=""
no_reboot=""
copy_config=""
enable_debug=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f | --flake)
      flake="$2"
      shift
      ;;
    -p | --port)
      ssh_port="$2"
      shift
      ;;
    -k | --key)
      luks_disk_key_path="$2"
      shift
      ;;
    --debug)
      enable_debug="-x"
      set -x
      ;;
    --no-reboot)
      no_reboot="y"
      ;;
    -c | --copy-config)
      copy_config="y"
      ;;
    *)
      if [[ -z ${ssh_host-} ]]; then
        ssh_host="$1"
      else
        echo 'No SSH host provided...'
        exit 1
      fi
      ;;
  esac
  shift
done

ssh_() {
  ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p "${ssh_port}" "root@${ssh_host}" "$@"
}

nix_build_() {
  nix build --print-out-paths --no-link "$@"
}

nix_copy_() {
  NIX_SSHOPTS="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${ssh_port}" \
    nix copy --to ssh://"root@${ssh_host}" "$@"
}

create_store_paths() {
  if [[ -n ${flake-} ]]; then
    if [[ $flake =~ ^(.*)\#([^\#\"]*)$ ]]; then
      flake="${BASH_REMATCH[1]}"
      flake_attr="${BASH_REMATCH[2]}"
    fi

    if [[ -z ${flake_attr-} ]]; then
      echo "Please provide flake URI path"
      exit 1
    fi

    disko_script=$(nix_build_ "${flake}#nixosConfigurations.\"${flake_attr}\".config.system.build.diskoScript")
    nixos_system=$(nix_build_ "${flake}#nixosConfigurations.\"${flake_attr}\".config.system.build.toplevel")

    if [[ ! -e ${disko_script} ]] || [[ ! -e ${nixos_system} ]]; then
      echo "${disko_script} and ${nixos_system} must be existing store paths"
      exit 1
    fi
  else
    echo "Please provide flake URI"
    exit 1
  fi
}

echo 'Generating hardware config...'
ssh_ "nixos-generate-config --no-filesystems --root /mnt --show-hardware-config" > hardware-configuration.nix
git add hardware-configuration.nix

echo 'Building configuration...'
create_store_paths

echo 'Copying over configuration to new host...'
nix_copy_ "$disko_script"
nix_copy_ "$nixos_system"

echo 'Sending keys...'
if [[ ! -n ${luks_disk_key_path-} ]]; then
  echo 'Please provide a key named "disk.key" send to host for unlocking LUKS...'
  exit 1
fi

rsync -e "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${ssh_port}" \
  "${luks_disk_key_path}" "root@${ssh_host}:/tmp/"
ssh_ "chmod 777 /tmp"

echo 'Running disko script...'
ssh_ "$disko_script"
ssh_ "ssh-keygen -t ed25519 -N '' -C '' -f /mnt/boot/host_ed25519_key"

echo 'Installing NixOS...'
ssh_ "nixos-install --no-root-passwd --no-channel-copy --system ${nixos_system}"

if [[ ! -n "${no_reboot-}" ]]; then
  echo 'Rebooting system...'
  ssh_ "reboot"
fi
