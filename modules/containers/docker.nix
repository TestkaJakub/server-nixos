{ ... }:

# ── Docker ─────────────────────────────────────────────────────────────────────
# Copied verbatim from containers/docker.nix on the PC.
# The docker group is assigned in system/users.nix.
{
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      userland-proxy = false;
      experimental   = true;
    };
  };

  virtualisation.oci-containers.backend = "docker";
}
