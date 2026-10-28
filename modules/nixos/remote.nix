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
}
