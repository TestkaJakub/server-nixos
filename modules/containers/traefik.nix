{ pkgs, ... }:

# ── Traefik — reverse proxy ────────────────────────────────────────────────────
# Fronts all services. TLS via step-ca ACME (running locally on this server).
#
# ── Adding a new service ───────────────────────────────────────────────────────
# Add these labels to the service's container extraOptions:
#
#   "--label=traefik.enable=true"
#   "--label=traefik.http.routers.MYSERVICE.rule=Host(`myservice.home`)"
#   "--label=traefik.http.routers.MYSERVICE.entrypoints=websecure"
#   "--label=traefik.http.routers.MYSERVICE.tls=true"
#   "--label=traefik.http.routers.MYSERVICE.tls.certresolver=step"
#   "--label=traefik.http.services.MYSERVICE.loadbalancer.server.port=PORT"
#
# Then add a Pi-hole local DNS record: myservice.home → 192.168.0.252
#
# ── Dashboard ──────────────────────────────────────────────────────────────────
# Reachable at https://traefik.home once Pi-hole has that DNS record.
# Port 8080 is also exposed directly for initial setup / debugging.
#
# ── Secrets ───────────────────────────────────────────────────────────────────
# No secret env file needed — step-ca is local, no credentials required.
# The CA fingerprint is baked into traefik.yml (see traefik-config.nix).
let
  traefikYml = "/home/jakub/docker-data/traefik/traefik.yml";
  acmeDir    = "/home/jakub/docker-data/traefik/acme";
  stepCert   = "/home/jakub/.step/certs/root_ca.crt";
in
{
  systemd.tmpfiles.rules = [
    "d /home/jakub/docker-data/traefik      0755 jakub jakub -"
    "d ${acmeDir}                            0700 jakub jakub -"
  ];

  virtualisation.oci-containers.containers.traefik = {
    image     = "traefik:v3.3";
    autoStart = true;

    environment = {
	 LEGO_CA_CERTIFICATES = "/certs/root_ca.crt";
    };

    ports = [
      "80:80"
      "443:443"
      "8080:8080"
    ];

    volumes = [
      "/var/run/docker.sock:${"/var/run/docker.sock"}:ro"
      "${stepCert}:/certs/root_ca.crt:ro"
      "${acmeDir}:/acme"
      "${traefikYml}:/traefik.yml:ro"
      "/home/jakub/docker-data/traefik/dynamic.yml:/traefik-dynamic.yml:ro"
    ];

    extraOptions = [
      "--group-add=131"
      "--dns=172.17.0.1"
      "--network=traefik"
      # Host networking for step-ca: Traefik needs to reach localhost:9000
      # We use host.docker.internal instead of --network=host so other
      # container networking still works correctly.
      "--add-host=host.docker.internal:host-gateway"
      "--health-cmd=traefik healthcheck --ping"

      "--label=traefik.enable=true"
      "--label=traefik.http.routers.dashboard.rule=Host(`traefik.home`)"
      "--label=traefik.http.routers.dashboard.entrypoints=websecure"
      "--label=traefik.http.routers.dashboard.tls=true"
      "--label=traefik.http.routers.dashboard.tls.certresolver=step"
      "--label=traefik.http.routers.dashboard.service=api@internal"
      "--health-start-period=180s"   
    ];
  };
}
