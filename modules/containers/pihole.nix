{ ... }:

# ── Pi-hole — DNS resolver for *.home ─────────────────────────────────────────
# Pi-hole is used ONLY for resolving .home service domains.
# It forwards all other queries (youtube.com etc.) to upstream DNS (1.1.1.1).
# It does NOT replace your router's DNS — you point only chosen devices at it.
#
# ── Pointing your main PC at Pi-hole ──────────────────────────────────────────
# NixOS (main PC) — add to your networking config:
#   networking.nameservers = [ "192.168.0.252" ];
# This makes your PC use Pi-hole for DNS. youtube.com still works fine
# because Pi-hole forwards unknown domains to 1.1.1.1.
#
# ── Adding a new service domain ───────────────────────────────────────────────
# Pi-hole web UI → Local DNS → DNS Records:
#   Domain: myservice.home
#   IP:     192.168.0.252
#
# Or drop a file into the dnsmasq volume:
#   echo "address=/myservice.home/192.168.0.252" \
#     >> /home/jakub/docker-data/pihole/dnsmasq/02-custom.conf
#   docker restart pihole
#
# ── Secrets ───────────────────────────────────────────────────────────────────
# /home/jakub/secrets/pihole.env must contain:
#   FTLCONF_webserver_api_password=your_strong_password
#
# ── Web UI ────────────────────────────────────────────────────────────────────
# https://pihole.home (via Traefik) once DNS record is added
# http://192.168.0.252:8053/admin (direct, always available as fallback)
{
  systemd.tmpfiles.rules = [
    "d /home/jakub/docker-data/pihole              0755 root root -"
    "d /home/jakub/docker-data/pihole/pihole       0755 root root -"
    "d /home/jakub/docker-data/pihole/dnsmasq      0755 root root -"
  ];

  virtualisation.oci-containers.containers.pihole = {
    image     = "pihole/pihole:latest";
    autoStart = true;

    environmentFiles = [ "/home/jakub/secrets/pihole.env" ];
	ports = [
	  "53:53/udp"
	  "53:53/tcp"
	];
	
	environment = {
	  TZ = "Europe/Warsaw";
	  PIHOLE_DNS_1     = "1.1.1.1";
	  PIHOLE_DNS_2     = "1.0.0.1";
	  BLOCKING_ENABLED = "false";
	  VIRTUAL_HOST     = "pihole.home";
	  CORS_HOSTS       = "pihole.home";
	};
    
    volumes = [
      "/home/jakub/docker-data/pihole/pihole:/etc/pihole"
      "/home/jakub/docker-data/pihole/dnsmasq:/etc/dnsmasq.d"
    ];

	extraOptions = [
	  "--network=traefik"
	  "--cap-add=NET_ADMIN"
	  "--label=traefik.enable=true"
	  "--label=traefik.http.routers.pihole.rule=Host(`pihole.home`)"
	  "--label=traefik.http.routers.pihole.entrypoints=websecure"
	  "--label=traefik.http.routers.pihole.tls=true"
	  "--label=traefik.http.routers.pihole.tls.certresolver=step"
	  "--label=traefik.http.services.pihole.loadbalancer.server.port=80"
	  "--label=traefik.http.middlewares.pihole-slash.redirectregex.regex=^https://pihole.home/?$"
	  "--label=traefik.http.middlewares.pihole-slash.redirectregex.replacement=https://pihole.home/admin/"
	  "--label=traefik.http.routers.pihole.middlewares=pihole-slash"
	];
  };
}
