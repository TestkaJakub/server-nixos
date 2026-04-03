{ pkgs, ... }:

# ── Traefik Docker network ─────────────────────────────────────────────────────
# All containers Traefik proxies must share this network.
# Created once via a oneshot systemd service — survives container restarts.
# Must start before any container that uses --network=traefik.
{
  systemd.services.docker-network-traefik = {
    description = "Create 'traefik' Docker network";
    wantedBy    = [ "multi-user.target" ];
    after       = [ "docker.service" ];
    requires    = [ "docker.service" ];

    serviceConfig = {
      Type            = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "create-traefik-network" ''
        ${pkgs.docker}/bin/docker network inspect traefik >/dev/null 2>&1 || \
          ${pkgs.docker}/bin/docker network create traefik
      '';
    };
  };
}
