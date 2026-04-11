{ config, ... }:

# ── Byparr ─────────────────────────────────────────────────────────────────────
# FlareSolverr-compatible Cloudflare bypass proxy.
# Runs as a Podman container on port 8191.
# API docs available at http://localhost:8191/docs
{
  virtualisation.oci-containers.containers.byparr = {
    image     = "ghcr.io/thephaseless/byparr:latest";
    ports     = [ "127.0.0.1:8191:8191" ];
    autoStart = true;
    environment = {
      HOST = "0.0.0.0";
      PORT = "8191";
      # PROXY_SERVER   = "";
      # PROXY_USERNAME = "";
      # PROXY_PASSWORD = "";
    };
  };

  networking.firewall.interfaces."eno1".allowedTCPPorts = [ 8191 ];
}
