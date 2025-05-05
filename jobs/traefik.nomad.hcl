job "traefik" {
  type        = "service"

  group "traefik" {
    count = 1

    network {
      mode = "host"

      port "http" {
        static = 80
      }

      port "https" {
        to     = 443
        static = 8443
      }

      port "dashboard" {
        static = 8888
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image = "traefik:v2.10"

        args = [
          "--entrypoints.web.address=:80",
          "--entrypoints.websecure.address=:443",
          "--entrypoints.dashboard.address=:8888",
          "--api.dashboard=true",
          "--api.insecure=true", # enables dashboard on /dashboard
          "--providers.consulCatalog=true",
          "--providers.consulCatalog.endpoint.address=192.168.1.160:8500",
          "--log.level=DEBUG"
        ]

        ports = ["http", "https", "dashboard"]
      }

      service {
        name     = "traefik"
        port     = "http"

        check {
          name     = "dashboard"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      restart {
        attempts = 5
        interval = "10m"
        delay    = "30s"
        mode     = "fail"
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}

