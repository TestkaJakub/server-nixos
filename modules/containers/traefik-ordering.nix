{ pkgs, ... }:
{
  systemd.services.docker-traefik = {
    after    = [ "docker-network-traefik.service" "docker-homelable-frontend.service" ];
    requires = [ "docker-network-traefik.service" ];
  };

  systemd.services.docker-homelable-frontend = {
    after    = [ "docker-network-traefik.service" ];
    requires = [ "docker-network-traefik.service" ];
  };

  systemd.services.docker-homelable-backend = {
    after    = [ "docker-network-traefik.service" ];
    requires = [ "docker-network-traefik.service" ];
  };

  systemd.services.docker-pihole = {
    after    = [ "docker-network-traefik.service" ];
    requires = [ "docker-network-traefik.service" ];
  };
}
