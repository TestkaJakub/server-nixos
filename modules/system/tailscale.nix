{ pkgs, config, ... }:
{
  services.tailscale = {
    enable             = true;
    useRoutingFeatures = "both";
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward"                   = 1;
    "net.ipv6.conf.all.forwarding"          = 1;
  };

  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts   = [ config.services.tailscale.port ];
    checkReversePath  = "loose";
  };

  environment.systemPackages = [ pkgs.tailscale ];
}
