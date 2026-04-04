{ pkgs, ... }:

# ── step-ca — local ACME certificate authority ─────────────────────────────────
# Runs on the server so Traefik can renew certs 24/7 without depending on
# your main PC being on.
#
# ── First-time bootstrap (run ONCE on the server, then never again) ────────────
#
#   sudo -u jakub bash
#   step ca init \
#     --name "Homelab CA" \
#     --dns "localhost" \
#     --dns "192.168.0.252" \
#     --address ":9000" \
#     --provisioner "acme" \
#     --deployment-type standalone \
#     --password-file /home/jakub/secrets/step-ca-password
#
#   # Add the ACME provisioner (allows Traefik to request certs automatically):
#   step ca provisioner add acme --type ACME
#
#   # Get the fingerprint — you'll need this in traefik.yml:
#   step certificate fingerprint /home/jakub/.step/certs/root_ca.crt
#
# ── Installing the root cert on your devices ───────────────────────────────────
#
#   # Copy root cert from server to your PC first:
#   scp jakub@192.168.0.252:~/.step/certs/root_ca.crt ~/homelab-root.crt
#
#   # NixOS (main PC) — add to security.pki.certificateFiles in your config:
#   #   security.pki.certificateFiles = [ /home/jakub/homelab-root.crt ];
#   # Then rebuild. This trusts it system-wide (curl, most apps, Chromium).
#
#   # Firefox (does NOT use the system store by default):
#   #   Settings → Privacy → View Certificates → Authorities → Import
#   #   Check "Trust this CA to identify websites"
#
# ── step-ca data lives at /home/jakub/.step — back this up ────────────────────
#   Especially /home/jakub/.step/secrets/ (root + intermediate keys)
#   If you lose these you'll need to re-bootstrap and re-trust on all devices.
{
  environment.systemPackages = with pkgs; [
    step-cli
    step-ca
  ];

  # step-ca password file must exist before bootstrap:
  #   mkdir -p /home/jakub/secrets
  #   echo "your_strong_password" > /home/jakub/secrets/step-ca-password
  #   chmod 600 /home/jakub/secrets/step-ca-password

  systemd.services.step-ca = {
    description = "step-ca local ACME certificate authority";
    wantedBy    = [ "multi-user.target" ];
    after       = [ "network.target" ];

    serviceConfig = {
      Type       = "simple";
      User       = "jakub";
      Group      = "jakub";
      ExecStart  = "${pkgs.step-ca}/bin/step-ca /home/jakub/.step/config/ca.json --password-file /home/jakub/secrets/step-ca-password";
      Restart    = "on-failure";
      RestartSec = "5s";
    };
  };

  systemd.services.step-ca-renew = {
    description = "Renew step-ca server certificate";
    after       = [ "step-ca.service" ];
    requires    = [ "step-ca.service" ];
  
    serviceConfig = {
      Type    = "oneshot";
      User    = "jakub";
      Group   = "jakub";
      ExecStart = pkgs.writeShellScript "step-ca-renew" ''
        ${pkgs.step-cli}/bin/step ca renew \
          /home/jakub/.step/certs/intermediate_ca.crt \
          /home/jakub/.step/secrets/intermediate_ca_key \
          --force
        systemctl restart step-ca
      '';
    };
  };
  
  systemd.timers.step-ca-renew = {
    wantedBy  = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}
