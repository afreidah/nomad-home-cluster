job "deluge" {
  datacenters = ["dc1"]
  type        = "service"

  meta {
    run_uuid = "${uuidv4()}"
  }

  group "deluge" {
    network {
      mode = "host"
    }

    task "deluge" {
      driver = "docker"

      config {
        image = "linuxserver/deluge"
        image_pull_timeout = "10m"
        network_mode = "host"
        volumes = [
          "local/deluge-config:/config",
          "local/downloads:/downloads"
        ]
      }

      env {
        PUID = "1000"
        PGID = "1000"
        TZ   = "UTC"
      }

      service {
        name     = "deluge"
        port     = "8112"
        provider = "consul"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.deluge.rule=Host(`deluge.alexanddakota.com`)",
          "traefik.http.routers.deluge.entrypoints=https",
          "traefik.http.routers.deluge.tls=true",
          "traefik.http.routers.deluge.tls.certresolver=dns",
          "traefik.http.services.deluge.loadbalancer.server.port=8112"
        ]

        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
          port     = 8112
        }
      }

      resources {
        cpu    = 200
        memory = 256
      }
    }
  }
}

