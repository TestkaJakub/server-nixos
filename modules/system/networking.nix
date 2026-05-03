{ lib, ... }:

# ── Networking ─────────────────────────────────────────────────────────────────
# Mirrors system/networking.nix on the PC (server subset — no Tailscale/Mullvad).
{
  networking = {
  	useDHCP = false;
  	nameservers = [ "127.0.0.1" "1.1.1.1" ];
    #networkmanager = {
    #	enable = true;
    #	insertNameservers = [ "127.0.0.1" ];
    #};
    #useDHCP               = lib.mkDefault false;
    #nameservers = [ "127.0.0.1" "1.1.1.1" ];	  

	defaultGateway = {
		address = "192.168.0.1";
		interface = "enp6s0";	
	};

	interfaces.enp6s0.ipv4.addresses = [{
		address = "192.168.0.252";
		prefixLength = 24;
	}];

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
