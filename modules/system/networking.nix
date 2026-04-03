{ lib, ... }:

# ── Networking ─────────────────────────────────────────────────────────────────
# Mirrors system/networking.nix on the PC (server subset — no Tailscale/Mullvad).
{
  networking = {
    networkmanager.enable = true;
    useDHCP               = lib.mkDefault true;

    firewall = {
      enable          = true;
      allowedTCPPorts = [ 22 ];

      # LAN-only ports — adjust interface name with `ip link` if not eno1
      interfaces."eno1".allowedTCPPorts = [
        8080
        9000
      ];
    };
  };

  services.resolved.enable = true;
}
