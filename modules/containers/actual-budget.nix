{ ... }:

# ── Actual Budget — envelope budgeting ────────────────────────────────────────
# Web UI: https://actual.home
# Local-first, open-source personal finance with cross-device sync.
#
# To add DNS record:
#   echo "192.168.0.252 actual.home" >> /home/jakub/docker-data/pihole/pihole/custom.list
#   docker exec pihole pihole reloaddns
#
# First run: visit https://actual.home and set a password when prompted.
# Data lives in /home/jakub/docker-data/actual-data — back this up!
{
  systemd.tmpfiles.rules = [
    "d /home/jakub/docker-data/actual-data 0755 jakub jakub -"
  ];

  virtualisation.oci-containers.containers.actual = {
    image     = "actualbudget/actual-server:latest";
    autoStart = true;

    volumes = [
      "/home/jakub/docker-data/actual-data:/data"
    ];

    extraOptions = [
      "--network=traefik"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.actual.rule=Host(`actual.home`)"
      "--label=traefik.http.routers.actual.entrypoints=websecure"
      "--label=traefik.http.routers.actual.tls=true"
      "--label=traefik.http.routers.actual.tls.certresolver=step"
      "--label=traefik.http.services.actual.loadbalancer.server.port=5006"
    ];
  };

  systemd.services.docker-actual = {
    after    = [ "docker-network-traefik.service" ];
    requires = [ "docker-network-traefik.service" ];
  };
}
