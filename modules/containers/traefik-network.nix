{ pkgs, ... }:

# ── Traefik Docker network ─────────────────────────────────────────────────────
# Created once before any container that needs it starts.
# Containers depend on this via systemd.services overrides in each file,
# NOT via dependsOn (which only accepts other container names).
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
