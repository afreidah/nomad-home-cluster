job "pihole" {
  type = "service"

  group "pihole" {
    count = 1

    network {
      mode = "host"

      port "dns" {
        static = 53
      }

      port "http" {
        static = 8080
      }

      port "https" {
        static = 443
      }
    }

    service {
      name     = "pihole"
      port     = "http"
      provider = "consul"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.pihole.rule=PathPrefix(`/pihole`)",
        "traefik.http.routers.pihole.entrypoints=web",
        "traefik.http.services.pihole.loadbalancer.server.port=8080",
        "traefik.http.routers.pihole.middlewares=pihole-strip",
        "traefik.http.middlewares.pihole-strip.stripprefix.prefixes=/pihole"
      ]

      check {
        name     = "pihole-http"
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
        port     = "http"
      }
    }

    task "pihole-task" {
      driver = "docker"

      env = {
        WEBPASSWORD = "test"
        DNS1        = "1.1.1.1"
        DNS2        = "8.8.8.8"
        TZ          = "America/Los_Angeles"
      }

      config {
        image = "pihole/pihole:latest"
        ports = ["dns", "http", "https"]

        volumes = [
          "dns:/etc/dnsmasq.d",
          # "etc-pihole:/etc/pihole"
        ]

        dns_servers = ["127.0.0.1", "1.1.1.1"]
        privileged  = true
      }

      restart {
        attempts = 5
        interval = "10m"
        delay    = "30s"
        mode     = "fail"
      }
    }
  }
}

