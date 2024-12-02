{ inputs, lib, ... }:

{
  # Don't mess with k8s
  networking.firewall.enable = lib.mkForce false;

  services.rke2 = {
    enable = true;
    # Also makes it act as an agent node
    role = "server";
    extraFlags = [
      "--disable=rke2-ingress-nginx"
      "--write-kubeconfig-mode=0644"
      "--kube-apiserver-arg=anonymous-auth=false"
    ];
    # settings.tls-san = [ "<TODO>" ];
  };
}
