job "traefik" {
  group "traefik" {

    network {
      mode = "host"
      port "web" {
        static = 80
      }
      port "websecure" {
        static = 443
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image = "traefik:v2.10"

        args = [
          "--entrypoints.web.address=:80",
          "--entrypoints.websecure.address=:443",
          "--api.dashboard=true",
          "--providers.consulCatalog=true",
          "--providers.consulCatalog.endpoint.address=192.168.1.160:8500",
          "--log.level=DEBUG"
        ]

        ports = ["web", "websecure"]
        cap_add = ["NET_BIND_SERVICE"]
        cap_drop = ["ALL"]
      }

      restart {
        attempts = 5
        interval = "10m"
        delay    = "30s"
        mode     = "fail"
      }

      service {
        name = "traefik"
        provider = "nomad"
        port = "web"

        check {
          name     = "traefik-ping"
          type     = "http"
          path     = "/ping"
          method   = "GET"
          interval = "10s"
          timeout  = "2s"
          port     = "web"
        }
      }
    }
  }
}
