job "traefik" {
  region      = "global"
  datacenters = ["dc1"]
  type        = "service"

  group "traefik" {
    count = 1

    network {
      port "http" {
        static = 8080
      }

      port "api" {
        static = 8081
      }
    }

    service {
      name = "traefik"

      check {
        name     = "alive"
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "traefik" {
      driver = "docker"

      env = {
        TRAEFIK_LOG_LEVEL = "DEBUG"
        TRAEFIK_ACCESSLOG = "true"
      
        CF_API_EMAIL       = "alex.freidah@gmail.com"
        CF_API_KEY         = "${NOMAD_VAR_cloudflare_api_key}" # or just hardcode for testing
      }

      logs {
        max_files     = 3
        max_file_size = 5
      }

      config {
        image        = "traefik:v2.2"
        network_mode = "host"

        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
          "local/acme.json:/etc/traefik/acme.json"
        ]
      }

      template {
        data = <<EOF
[entryPoints]
  [entryPoints.http]
    address = ":80"

  [entryPoints.https]
    address = ":443"

  [entryPoints.traefik]
    address = ":8081"

[api]
  dashboard = true
  insecure  = false

[providers.consulCatalog]
  prefix           = "traefik"
  exposedByDefault = false

  [providers.consulCatalog.endpoint]
    address = "192.168.1.225:8500"
    scheme  = "http"

[certificatesResolvers.dns]
  [certificatesResolvers.dns.acme]
    email = "you@example.com"
    storage = "/etc/traefik/acme.json"

    [certificatesResolvers.dns.acme.dnsChallenge]
      provider = "cloudflare"
      delayBeforeCheck = 0

EOF

        destination = "local/traefik.toml"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}

