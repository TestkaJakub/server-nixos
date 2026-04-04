{ ... }:

# ── Gluetun ────────────────────────────────────────────────────────────────────
# Mullvad WireGuard VPN gateway container.
# qbittorrent.nix routes its traffic through this container's network stack.
#
# Secrets: ~/secrets/gluetun.env must contain:
#   WIREGUARD_PRIVATE_KEY=your_key
#   WIREGUARD_ADDRESSES=10.x.x.x/32
{
  virtualisation.oci-containers.containers.gluetun = {
    image     = "qmcgaw/gluetun";
    autoStart = true;

    environmentFiles = [ "/home/jakub/secrets/gluetun.env" ];
    environment = {
      VPN_SERVICE_PROVIDER = "mullvad";
      VPN_TYPE             = "wireguard";
      SERVER_COUNTRIES     = "Poland";
    };

    ports = [
      "6881:6881"
      "6881:6881/udp"
      "8085:8085"
    ];

	extraOptions = [
	  "--cap-add=NET_ADMIN"
	  "--device=/dev/net/tun:/dev/net/tun"
	  ''--health-cmd=["ping","-c","1","1.1.1.1"]''
	  "--health-interval=30s"
	  "--health-timeout=10s"
	  "--health-retries=3"
	  "--health-start-period=60s"
	  "--network=traefik"
	  "--label=traefik.enable=true"
	  "--label=traefik.http.routers.qbittorrent.rule=Host(`qbittorrent.home`)"
	  "--label=traefik.http.routers.qbittorrent.entrypoints=websecure"
	  "--label=traefik.http.routers.qbittorrent.tls=true"
	  "--label=traefik.http.routers.qbittorrent.tls.certresolver=step"
	  "--label=traefik.http.services.qbittorrent.loadbalancer.server.port=8085"
	];
  };
}
