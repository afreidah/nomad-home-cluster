job "registry-ui" {
  datacenters = ["dc1"]
  type        = "service"

  meta {
    run_uuid = "${uuidv4()}"
  }

  group "ui" {
    network {
      port "http" {
        static = 8086 
      }
    }

    task "ui" {
      driver = "docker"

      env {
        REGISTRY_TITLE       = "Home_Registry"
        NGINX_PROXY_PASS_URL = "http://registry.service.consul:5000"
        NGINX_LISTEN_PORT = "http"
      }

      config {
        image       = "joxit/docker-registry-ui:master-debian"
        image_pull_timeout = "10m"
        ports       = ["http"]
      }

      service {
        name = "registry-ui"
        port = "http"
      }
    }
  }
}
