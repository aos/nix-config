{ pkgs, ... }:

{
  virtualisation = {
    libvirtd.enable = true;

    podman = {
      enable = true;

      # create a 'docker' alias for podman
      dockerCompat = true;

      # Required by containers under podman-compose to talk to each other
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  programs.virt-manager.enable = true;
}
