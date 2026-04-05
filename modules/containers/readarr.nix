{ ... }:

# ── Readarr — books & audiobooks automation ────────────────────────────────────
# Web UI: https://readarr.home
# To add DNS record:
#   echo "192.168.0.252 readarr.home" >> /home/jakub/docker-data/pihole/pihole/custom.list
#   docker exec pihole pihole reloaddns
{
  systemd.tmpfiles.rules = [
    "d /home/jakub/docker-data/readarr-config 0755 jakub jakub -"
    "d /mnt/data/media/books                   0775 jakub jakub -"
  ];

  virtualisation.oci-containers.containers.readarr = {
    image = "lscr.io/linuxserver/readarr:develop"
    autoStart = true;

    environment = {
      PUID = "1000";
      PGID = "1000";
      TZ   = "Europe/Warsaw";
    };

    volumes = [
      "/home/jakub/docker-data/readarr-config:/config"
      "/mnt/data:/data"
    ];

    extraOptions = [
      "--network=traefik"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.readarr.rule=Host(`readarr.home`)"
      "--label=traefik.http.routers.readarr.entrypoints=websecure"
      "--label=traefik.http.routers.readarr.tls=true"
      "--label=traefik.http.routers.readarr.tls.certresolver=step"
      "--label=traefik.http.services.readarr.loadbalancer.server.port=8787"
    ];
  };

  systemd.services.docker-readarr = {
    after    = [ "docker-network-traefik.service" ];
    requires = [ "docker-network-traefik.service" ];
  };
}
