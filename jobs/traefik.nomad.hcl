job "traefik" {
  datacenters = ["dc1"]
  type        = "service"

  group "traefik" {
    task "traefik" {
      driver = "docker"

      config {
        image        = "traefik:v2.10"
        command      = "traefik"
        args         = ["--configFile=/etc/traefik/traefik.yml"]
        network_mode = "host"
        volumes = [
          "/Users/alexfreidah/tools/nomad-home-cluster/config/traefik/traefik.yml:/etc/traefik/traefik.yml"
        ]
      }

      resources {
        cpu    = 200
        memory = 256
        network {
          mbits = 10
          port "http" {
            static = 80
          }
          port "https" {
            static = 443
          }
        }
      }

      service {
        name = "traefik"
        port = "http"
        tags = ["traefik"]
        check {
          type     = "http"
          path     = "/ping"
          interval = "10s"
          timeout  = "2s"
        }
      }

      restart {
        attempts = 5
        interval = "2m"
        delay    = "10s"
        mode     = "delay"
      }
    }
  }
}
