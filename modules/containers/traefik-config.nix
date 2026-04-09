{ ... }:
{
  system.activationScripts.traefikConfig = {
    text = ''
      mkdir -p /home/jakub/docker-data/traefik
      mkdir -p /home/jakub/docker-data/traefik/acme

      cat > /home/jakub/docker-data/traefik/dynamic.yml << 'DYNAMICEOF'
http:
  routers:
    pihole:
      rule: "Host(`pihole.home`)"
      entryPoints:
        - websecure
      middlewares:
        - pihole-slash
      tls:
        certResolver: step
      service: pihole
    ping:
      rule: "Host(`traefik.home`) && Path(`/ping`)"
      entryPoints:
        - websecure
      tls:
        certResolver: step
      service: ping@internal
    http-catchall:
      rule: "HostRegexp(`{host:.+}`)"
      entryPoints:
        - web
      priority: 1
      middlewares:
        - https-redirect
      service: noop@internal
  middlewares:
    pihole-slash:
      redirectRegex:
        regex: "^https://pihole\\.home/?$"
        replacement: "https://pihole.home/admin/"
    https-redirect:
      redirectScheme:
        scheme: https
        permanent: true
  services:
    pihole:
      loadBalancer:
        servers:
          - url: "http://172.17.0.1:8053"
DYNAMICEOF

      cat > /home/jakub/docker-data/traefik/traefik.yml << 'TRAEFIKEOF'
api:
  dashboard: true
  insecure: false

ping: {}

log:
  level: DEBUG

entryPoints:
  web:
    address: ":80"
    # http:
    #   redirections:
    #     entryPoint:
    #       to: websecure
    #       scheme: https
    #       permanent: true
  websecure:
    address: ":443"

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
  file:
    filename: "/traefik-dynamic.yml"
    watch: true

certificatesResolvers:
  step:
    acme:
      email: "jakub@home.local"
      storage: "/acme/acme.json"
      caServer: "https://host.docker.internal:9000/acme/acme/directory"
      certificatesDuration: 24
      httpChallenge:
        entryPoint: web

serversTransport:
  rootCAs:
    - "/certs/root_ca.crt"
TRAEFIKEOF

      chown jakub:jakub /home/jakub/docker-data/traefik/traefik.yml
      chown jakub:jakub /home/jakub/docker-data/traefik/dynamic.yml
    '';
    deps = [];
  };
}
