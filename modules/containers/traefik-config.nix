{ ... }:

# ── Traefik static config ──────────────────────────────────────────────────────
# Written via activation script so it is always in sync with the Nix config.
# After running step ca init, replace YOUR_FINGERPRINT_HERE with the real value.
#
# To get the fingerprint:
#   step certificate fingerprint /home/jakub/.step/certs/root_ca.crt
{
  system.activationScripts.traefikConfig = {
    text = ''
      mkdir -p /home/jakub/docker-data/traefik
      cat > /home/jakub/docker-data/traefik/traefik.yml << 'TRAEFIKEOF'
api:
  dashboard: true
  insecure: false

log:
  level: INFO

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
          permanent: true
  websecure:
    address: ":443"

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
    network: traefik

certificatesResolvers:
  step:
    acme:
      email: "jakub@home.local"
      storage: "/acme/acme.json"
      # step-ca ACME directory — reachable via host.docker.internal
      caServer: "https://host.docker.internal:9000/acme/acme/directory"
      certificatesDuration: 24
      httpChallenge:
        entryPoint: web

# Trust our local step-ca root cert for the caServer connection itself
serversTransport:
  rootCAs:
    - "/certs/root_ca.crt"
TRAEFIKEOF
      chown jakub:jakub /home/jakub/docker-data/traefik/traefik.yml
    '';
    deps = [];
  };
}
