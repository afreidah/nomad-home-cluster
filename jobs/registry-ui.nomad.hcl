job "registry-ui" {
  datacenters = ["dc1"]
  type        = "service"

  group "ui" {
    count = 1

    network {
      port "http" {
        static = 8084
        to     = 80
      }
    }

    service {
      name     = "registry-ui"
      port     = "http"
      provider = "consul"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.registry-ui.rule=Host(`registry-ui.localhost`)",
        "traefik.http.routers.registry-ui.entrypoints=http",
        "traefik.http.services.registry-ui.loadbalancer.server.port=80"
      ]

      check {
        name     = "http-check"
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
        port     = "http"
      }
    }

    task "ui" {
      driver = "docker"

      config {
        image = "joxit/docker-registry-ui:1.5-static"
        ports = ["http"]
        
      }

      env = {
        REGISTRY_URL  = "http://192.168.1.225:5000"
        DELETE_IMAGES = "false"
      }

      logs {
        max_files     = 1
        max_file_size = 10
      }

      restart {
        attempts = 3
        interval = "5m"
        delay    = "15s"
        mode     = "fail"
      }
    }
  }
}

