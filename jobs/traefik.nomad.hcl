job "traefik" {
  datacenters = ["dc1"]
  type        = "service"

  group "traefik" {
    count = 1

    network {
      mode = "host"

      port "web" {
        static = 80
      }

      port "dashboard" {
        static = 8080
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image = "traefik:v2.10"
        ports = ["web", "dashboard"]
        args = [
          "--api.dashboard=true",
          "--api.insecure=false",
          "--entrypoints.web.address=:${NOMAD_PORT_web}",
          "--entrypoints.dashboard.address=:${NOMAD_PORT_dashboard}",
          "--api=true",  # exposes api@internal
          "--providers.consulcatalog=true",
          "--providers.consulcatalog.endpoint.address=192.168.1.160:8500",
          "--providers.consulcatalog.endpoint.scheme=http",
          "--log.level=DEBUG"
        ]
      }
    }

    service {
      name = "traefik-dashboard"
      port = "dashboard"
      provider = "consul"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.api.rule=PathPrefix(`/`)",
        "traefik.http.routers.api.entrypoints=dashboard",
        "traefik.http.routers.api.service=api@internal"
      ]
    }
  }
}

