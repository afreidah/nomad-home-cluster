job "traefik" {
  datacenters = ["dc1"]
  type        = "service"

  group "traefik" {
    count = 1

    network {
      mode = "host"

      port "http" {
        static = 81
      }
      port "admin" {
        static = 80
      }
    }

    service {
      name = "traefik-http"
      provider = "consul"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.traefik.rule=PathPrefix(`/traefik`)",
        "traefik.http.routers.traefik.entrypoints=web",
        "traefik.http.routers.traefik.middlewares=traefik-stripprefix,traefik-replacepath",
        "traefik.http.middlewares.traefik-stripprefix.stripprefix.prefixes=/traefik",
        "traefik.http.middlewares.traefik-replacepath.replacepathregex.regex=^/dashboard$$",
        "traefik.http.middlewares.traefik-replacepath.replacepathregex.replacement=/dashboard",
        "traefik.http.services.traefik.loadbalancer.server.port=80"
      ]
    }

    task "server" {
      driver = "docker"
      config {
        image = "traefik:v2.10"
        ports = ["admin", "http"]
        args = [
          "--api.dashboard=true",
          "--api.insecure=true", ### For Test only, please do not use that in production
          "--entrypoints.web.address=:${NOMAD_PORT_http}",
          "--entrypoints.traefik.address=:${NOMAD_PORT_admin}",
          "--providers.consulcatalog=true",
          "--providers.consulcatalog.endpoint.address=192.168.1.160:8500",
          "--log.level=DEBUG"
        ]
      }
    }
  }
}
