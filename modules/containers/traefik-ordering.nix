{ ... }:

# ── Ensure all containers wait for the traefik network ────────────────────────
# NixOS generates systemd services named docker-<containername> for each
# oci-container. We patch their After/Requires here so the network exists first.
{
  systemd.services.docker-traefik = {
    after    = [ "docker-network-traefik.service" ];
    requires = [ "docker-network-traefik.service" ];
  };

	systemd.services.docker-pihole = {
	  postStart = ''
	    sleep 3
	    ${pkgs.docker}/bin/docker network connect traefik pihole || true
	  '';
	};
}
