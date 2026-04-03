{ lib, ... }:

# ── Networking ─────────────────────────────────────────────────────────────────
# Mirrors system/networking.nix on the PC (server subset — no Tailscale/Mullvad).
{
  networking = {
    networkmanager.enable = true;
    useDHCP               = lib.mkDefault true;

	firewall = {
	  enable          = true;
	  allowedTCPPorts = [ 22 80 443 53 ];
	  allowedUDPPorts = [ 53 ];

	  interfaces."eno1".allowedTCPPorts = [
	    8080   # Traefik dashboard direct
	    8053   # Pi-hole UI direct fallback
	    9000   # step-ca (LAN access so you can copy the root cert from your PC)
	  ];
	};
  };

  services.resolved.enable = true;
}
