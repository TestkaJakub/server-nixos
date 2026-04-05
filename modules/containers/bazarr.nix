{ ... }:

# ── Bazarr — subtitle automation ───────────────────────────────────────────────
# Automatically downloads subtitles for Radarr and Sonarr content.
# Web UI: https://bazarr.home
# To add DNS record:
#   echo "192.168.0.252 bazarr.home" >> /home/jakub/docker-data/pihole/pihole/custom.list
#   docker exec pihole pihole reloaddns
{
  systemd.tmpfiles.rules = [
    "d /home/jakub/docker-data/bazarr-config 0755 jakub jakub -"
  ];

  virtualisation.oci-containers.containers.bazarr = {
    image     = "lscr.io/linuxserver/bazarr:latest";
    autoStart = true;

    environment = {
      PUID = "1000";
      PGID = "1000";
      TZ   = "Europe/Warsaw";
    };

    volumes = [
      "/home/jakub/docker-data/bazarr-config:/config"
      "/mnt/data/media:/media"
    ];

    extraOptions = [
      "--network=traefik"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.bazarr.rule=Host(`bazarr.home`)"
      "--label=traefik.http.routers.bazarr.entrypoints=websecure"
      "--label=traefik.http.routers.bazarr.tls=true"
      "--label=traefik.http.routers.bazarr.tls.certresolver=step"
      "--label=traefik.http.services.bazarr.loadbalancer.server.port=6767"
    ];
  };

  systemd.services.docker-bazarr = {
    after    = [ "docker-network-traefik.service" ];
    requires = [ "docker-network-traefik.service" ];
  };
}
