job "registry" {
  datacenters = ["dc1"]
  type        = "service"

  meta {
    run_uuid = "${uuidv4()}"
  }

  group "mirror" {
    network {
      mode = "host"
      port "registry" {
        static = 5000
      }
    }

    # host‑side cache dir
    volume "cache" {
      type      = "host"
      source    = "registry_data"   # /opt/nomad/data/registry
      read_only = false
    }

    task "registry" {
      driver = "docker"

      config {
        image        = "registry:2"
        image_pull_timeout = "10m"
        network_mode = "host"
        # ⬆︎ NO command/args override – default entrypoint is fine
        volumes = [
          "local/config:/etc/docker/registry",
        ]
      }

      env { TZ = "UTC" }

      # mount persistent cache
      volume_mount {
        volume      = "cache"
        destination = "/var/lib/registry"
        read_only   = false
      }

      template {
        destination = "local/config/config.yml"
        change_mode = "restart"
        perms       = "0644"
      
        data = <<EOT
version: 0.1
log:
  level: info

storage:
  filesystem:
    rootdirectory: /var/lib/registry

proxy:
  remoteurl: https://registry-1.docker.io

http:
  addr: :5000          # ← forces the listener to stay on 5000
EOT
      }

      service {
        name     = "docker-mirror"
        provider = "consul"
        port     = "registry"

        check {
          name         = "http-registry"
          type         = "http"
          path         = "/v2/"
          interval     = "10s"
          timeout      = "3s"
        }
      }
    }
  }
}

