{
  config,
  ...
}:
{
  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "biggie";
        protocol = "ssh-ng";
        sshUser = "aos";
        sshKey = "/home/aos/.ssh/id_tower";
        systems = [ "x86_64-linux" ];
        maxJobs = 4;
      }
    ]; 
    settings.builders-use-substitutes = true;
  };
  programs.ssh.knownHosts.biggie = {
    hostNames = [ "biggie" ];
    publicKeyFile = ../../sops/keys/hosts/biggie_ssh_host_ed25519_key.pub;
  };
}
