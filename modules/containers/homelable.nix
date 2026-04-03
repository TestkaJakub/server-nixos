{ pkgs, ... }:

# ── Homelable — homelab infrastructure visualizer ─────────────────────────────
# Builds from source since no pre-built images are published.
# Build is done once via a oneshot systemd service — only rebuilds if the
# images don't exist. To force a rebuild:
#   docker rmi homelable-backend:local homelable-frontend:local
#   sudo systemctl restart homelable-build.service
#
# Web UI: https://homelable.home
# Default login: set via ~/secrets/homelable.env
#
# To add DNS record:
#   echo "192.168.0.252 homelable.home" >> /home/jakub/docker-data/pihole/pihole/custom.list
#   docker exec pihole pihole reloaddns
{
  systemd.tmpfiles.rules = [
    "d /home/jakub/docker-data/homelable 0755 jakub jakub -"
    "d /opt/homelable                     0755 jakub jakub -"
  ];

  # ── Build service ────────────────────────────────────────────────────────────
  # Clones the repo and builds Docker images if they don't exist yet.
  systemd.services.homelable-build = {
    description = "Build Homelable Docker images from source";
    wantedBy    = [ "multi-user.target" ];
    after       = [ "docker.service" "network-online.target" ];
    requires    = [ "docker.service" ];
    before      = [
      "docker-homelable-backend.service"
      "docker-homelable-frontend.service"
    ];

    serviceConfig = {
      Type            = "oneshot";
      RemainAfterExit = true;
      User            = "root";
      ExecStart = pkgs.writeShellScript "build-homelable" ''
        set -e

        if ! ${pkgs.docker}/bin/docker image inspect homelable-backend:local >/dev/null 2>&1 || \
           ! ${pkgs.docker}/bin/docker image inspect homelable-frontend:local >/dev/null 2>&1; then

          echo "Cloning Homelable..."
          if [ -d /opt/homelable/.git ]; then
            cd /opt/homelable && ${pkgs.git}/bin/git pull
          else
            ${pkgs.git}/bin/git clone https://github.com/Pouzor/homelable /opt/homelable
          fi

          echo "Building backend image..."
          ${pkgs.docker}/bin/docker build \
            -f /opt/homelable/Dockerfile.backend \
            -t homelable-backend:local \
            /opt/homelable

          echo "Building frontend image..."
          ${pkgs.docker}/bin/docker build \
            -f /opt/homelable/Dockerfile.frontend \
            -t homelable-frontend:local \
            /opt/homelable

          echo "Homelable images built successfully."
        else
          echo "Homelable images already exist, skipping build."
        fi
      '';
    };
  };

  # ── Backend ──────────────────────────────────────────────────────────────────
  virtualisation.oci-containers.containers.homelable-backend = {
    image     = "homelable-backend:local";
    autoStart = true;

    environmentFiles = [ "/home/jakub/secrets/homelable.env" ];
    environment = {
      SQLITE_PATH  = "/app/data/homelab.db";
      CORS_ORIGINS = ''["https://homelable.home"]'';
    };

    volumes = [
      "/home/jakub/docker-data/homelable:/app/data"
    ];

    extraOptions = [
      "--network=traefik"
      "--cap-add=NET_RAW"
    ];
  };

  # ── Frontend ─────────────────────────────────────────────────────────────────
  virtualisation.oci-containers.containers.homelable-frontend = {
    image     = "homelable-frontend:local";
    autoStart = true;

    extraOptions = [
      "--network=traefik"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.homelable.rule=Host(`homelable.home`)"
      "--label=traefik.http.routers.homelable.entrypoints=websecure"
      "--label=traefik.http.routers.homelable.tls=true"
      "--label=traefik.http.routers.homelable.tls.certresolver=step"
      "--label=traefik.http.services.homelable.loadbalancer.server.port=80"
    ];
  };

  # ── Ordering ─────────────────────────────────────────────────────────────────
  systemd.services.docker-homelable-backend = {
    after    = [ "homelable-build.service" "docker-network-traefik.service" ];
    requires = [ "homelable-build.service" "docker-network-traefik.service" ];
  };

  systemd.services.docker-homelable-frontend = {
    after    = [ "docker-homelable-backend.service" ];
    requires = [ "docker-homelable-backend.service" ];
  };
}
