{ lib, ... }:

# ── Networking ─────────────────────────────────────────────────────────────────
# Mirrors system/networking.nix on the PC (server subset — no Tailscale/Mullvad).
{
  networking = {
    networkmanager.enable = true;
    useDHCP               = lib.mkDefault true;

	firewall = {
	  enable          = true;
	  allowedTCPPorts = [ 22 80 443 53 9000 ];  # added 9000
	  allowedUDPPorts = [ 53 ];

	  interfaces."eno1".allowedTCPPorts = [
	    8080
	    8053
	    9000
	  ];
	};
  };

  services.resolved = {
    enable = true;
    extraConfig = ''
      DNSStubListener=no
    '';
  };
}
