{ lib, ... }:

# ── Networking ─────────────────────────────────────────────────────────────────
# Mirrors system/networking.nix on the PC (server subset — no Tailscale/Mullvad).
{
  networking = {
    networkmanager = {
    	enable = true;
    	insertNameservers = [ "127.0.0.1" ];
    	unmanaged = [ "enp5s0" ];
    };
    useDHCP               = lib.mkDefault true;
    nameservers = [ "127.0.0.1" "1.1.1.1" ];

    interfaces.enp5s0 = {
	    wakeOnLan.enable = true;
	    ipv4.addresses = [{
	      address = "192.168.0.251";
	      prefixLength = 24;
	    }];
	  };

	firewall = {
	  enable          = true;
	  allowedTCPPorts = [ 22 80 443 53 9000 8053 ];  # added 9000
	  allowedUDPPorts = [ 53 ];

	 extraCommands = ''
	    iptables -I INPUT -p udp --dport 53 -j ACCEPT
	    iptables -I INPUT -p tcp --dport 53 -j ACCEPT
	    iptables -I INPUT -i tailscale0 -p tcp --dport 80 -j ACCEPT
	    iptables -I INPUT -i tailscale0 -p tcp --dport 443 -j ACCEPT
	    iptables -I INPUT -i tailscale0 -p tcp --dport 8080 -j ACCEPT
	  '';

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
	security.pki.certificateFiles = [
	  ../meta/homelab-root.crt
	];
}
