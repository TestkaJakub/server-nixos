{ ... }:

# ── Habitica — habit & task tracker ───────────────────────────────────────────
# Web UI: https://habitica.home
# A gamified habit tracker — level up your 人生 by completing real-life tasks.
#
# ── Secrets (/home/jakub/secrets/habitica.env) ────────────────────────────────
# MONGODB_PASSWORD=<strong password>
# HABITICA_ADMIN_EMAIL=<your email>
# NODE_ENV=production
# BASE_URL=https://habitica.home
# NODE_DB_URI=mongodb://habitica:<MONGODB_PASSWORD>@habitica-db:27017/habitica
# SMTP_FROM=habitica@home.local     # optional — for email notifications
#
# ── Secrets (/home/jakub/secrets/habitica-db.env) ─────────────────────────────
# MONGO_INITDB_ROOT_USERNAME=habitica
# MONGO_INITDB_ROOT_PASSWORD=<same as MONGODB_PASSWORD above>
# MONGO_INITDB_DATABASE=habitica
#
# ── First run ─────────────────────────────────────────────────────────────────
# Visit https://habitica.home and register — 一 番 最初の人 becomes admin.
# Data lives in /home/jakub/docker-data/habitica-db — back this up!
#
# To add DNS record:
#   echo "192.168.0.252 habitica.home" >> /home/jakub/docker-data/pihole/pihole/custom.list
#   docker exec pihole pihole reloaddns
{
  systemd.tmpfiles.rules = [
    "d /home/jakub/docker-data/habitica-db 0755 jakub jakub -"
  ];

  # ── Database ─────────────────────────────────────────────────────────────────
  virtualisation.oci-containers.containers.habitica-db = {
    image     = "mongo:6";
    autoStart = true;

    environmentFiles = [ "/home/jakub/secrets/habitica-db.env" ];

    cmd = [ "--replSet" "rs" "--bind_ip_all" "--keyFile" "/etc/mongo/keyfile" ];

	  volumes = [
	    "/home/jakub/docker-data/habitica-db:/data/db"
	    "/home/jakub/secrets/habitica-mongo-keyfile:/etc/mongo/keyfile:ro"
	  ];

    extraOptions = [
      "--network=traefik"
      "--network-alias=habitica-db"
      "--health-cmd=mongosh --eval 'db.runCommand({ ping: 1 })' --quiet"
      "--health-interval=10s"
      "--health-timeout=5s"
      "--health-retries=5"
    ];
  };

  # ── App ───────────────────────────────────────────────────────────────────────
  virtualisation.oci-containers.containers.habitica = {
    image = "docker.io/awinterstein/habitica-server:latest";
    autoStart = true;
    dependsOn = [ "habitica-db" ];

    environmentFiles = [ "/home/jakub/secrets/habitica.env" ];

    extraOptions = [
      "--network=traefik"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.habitica.rule=Host(`habitica.home`)"
      "--label=traefik.http.routers.habitica.entrypoints=websecure"
      "--label=traefik.http.routers.habitica.tls=true"
      "--label=traefik.http.routers.habitica.tls.certresolver=step"
      "--label=traefik.http.services.habitica.loadbalancer.server.port=3000"
    ];
  };

  # ── Ordering ─────────────────────────────────────────────────────────────────
  systemd.services.docker-habitica-db = {
    after    = [ "docker-network-traefik.service" ];
    requires = [ "docker-network-traefik.service" ];
  };

  systemd.services.docker-habitica = {
    after    = [ "docker-network-traefik.service" "docker-habitica-db.service" ];
    requires = [ "docker-network-traefik.service" "docker-habitica-db.service" ];
  };
}
