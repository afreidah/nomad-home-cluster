job "pihole" {
  datacenters = ["dc1"]
  type = "service"

  group "pihole" {
    count = 1

    network {
      mode = "host"

      port "dns" {
        static = 54
        to = 53
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
        "traefik.http.routers.pihole.rule=PathPrefix(`/admin`)",
        "traefik.http.routers.pihole.entrypoints=web",
        "traefik.http.services.pihole.loadbalancer.server.port=8080"
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
        DNS1        = "1.1.1.1"
        DNS2        = "8.8.8.8"
        TZ          = "America/Los_Angeles"
        FTLCONF_LOCAL_IPV4 = "0.0.0.0"
        FTLCONF_webserver_api_password = "test"
      }


      config {
        image = "pihole/pihole:latest"
        ports = ["dns", "http", "https"]

        volumes = [
          "dns:/etc/dnsmasq.d",
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

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}

