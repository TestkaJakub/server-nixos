{ config, ... }:

# ── Byparr ─────────────────────────────────────────────────────────────────────
# FlareSolverr-compatible Cloudflare bypass proxy.
# Runs as a Podman container on port 8191.
# API docs available at http://localhost:8191/docs
#
# Optional env vars (uncomment as needed):
#   PROXY_SERVER   — protocol://host:port
#   PROXY_USERNAME — proxy auth username
#   PROXY_PASSWORD — proxy auth password
{
  virtualisation.podman = {
    enable       = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.oci-containers.backend = "podman";

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

  # Expose on LAN interface — mirrors the pattern in system/networking.nix
  networking.firewall.interfaces."eno1".allowedTCPPorts = [ 8191 ];
}
