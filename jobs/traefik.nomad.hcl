###############################################################################
# Traefik — Nomad service job
#
# * Runs the Traefik reverse proxy using the official traefik image.
# * Handles HTTPS routing for services via Consul and DNS challenge.
# * Persists configuration and ACME certificates on the host.
# * Exposes HTTP on port 8080, HTTPS on port 8443, and dashboard on port 8081.
# * Registers service with Consul for discovery and health checks.
###############################################################################

variable "cf_api_token" {
  type      = string
  description = "Cloudflare API token with DNS:Edit on alexanddakota.com"
}

job "traefik" {
  region      = "global"
  datacenters = ["dc1"]
  type        = "service"

  meta {
    run_uuid = "${uuidv4()}"
  }

  group "traefik" {
    count = 1

    # health check service (host‑network, so ports are informational)
    service {
      name = "traefik"
      port = "8080"

      check {
        name     = "alive"
        type     = "tcp"
        port     = "8080"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "traefik" {
      driver = "docker"

      env = {
        TRAEFIK_LOG_LEVEL        = "DEBUG"
        CLOUDFLARE_DNS_API_TOKEN = "${var.cf_api_token}"
      }

      logs {
        max_files     = 3
        max_file_size = 5
      }

      config {
        image        = "traefik:v2.10"
        network_mode = "host"
        image_pull_timeout = "10m"

        volumes = [
          "/etc/nomad/data/traefik:/etc/traefik",
          "local/traefik.toml:/etc/traefik/traefik.toml",
          "local/dynamic:/etc/traefik/dynamic",
          "/opt/nomad/data/traefik/acme.json:/etc/traefik/acme.json"
        ]
      }

      # ---------- static config ----------
      template {
        destination = "local/traefik.toml"
        perms       = "0644"
        change_mode = "noop"
        data = <<-EOF
  #######################################################################
  # EntryPoints
  #######################################################################
  [entryPoints]
    [entryPoints.http]
      address = "0.0.0.0:8080"

    [entryPoints.https]
      address = "0.0.0.0:8443"

    [entryPoints.traefik]
      address = "0.0.0.0:8081"

  #######################################################################
  # API (secure mode)
  #######################################################################
  [api]
    dashboard = true
    insecure  = false

  #######################################################################
  # Consul Catalog provider
  #######################################################################
  [providers.consulCatalog]
    prefix           = "traefik"
    exposedByDefault = false
    [providers.consulCatalog.endpoint]
      address = "192.168.1.225:8500"
      scheme  = "http"

  #######################################################################
  # ACME via Cloudflare DNS‑01
  #######################################################################
  [certificatesResolvers.dns]
    [certificatesResolvers.dns.acme]
      email   = "alex.freidah@gmail.com"
      storage = "/etc/traefik/acme.json"
      [certificatesResolvers.dns.acme.dnsChallenge]
        provider = "cloudflare"

  #######################################################################
  # Dynamic routers/services loaded from files in /etc/traefik/dynamic
  #######################################################################
  [providers.file]
    directory = "/etc/traefik/dynamic"
    watch     = true
EOF
      }

      # ---------- dynamic dashboard router ----------
      template {
        destination = "local/dynamic/dashboard.toml"
        perms       = "0644"
        change_mode = "noop"
        data = <<-EOF
          [http.routers.dashboard]
            rule        = 'Host(`traefik.alexanddakota.com`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))'
            entryPoints = ["https"]
            service     = "api@internal"
            [http.routers.dashboard.tls]
              certResolver = "dns"
        EOF
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }

    //task "dnat" {
    //  driver = "exec"
    //
    //  # A tiny shell script delivered via template
    //  template {
    //    destination = "local/dnat.sh"
    //    perms       = "0755"
    //    data        = <<-EOFSH
    //      #!/usr/bin/env sh
    //      set -eu
    //
    //      add_rules() {
    //        iptables -t nat -C PREROUTING -i wg0 -p tcp --dport 80  -j DNAT --to-destination 127.0.0.1:8080 2>/dev/null || \
    //          iptables -t nat -A PREROUTING -i wg0 -p tcp --dport 80  -j DNAT --to-destination 127.0.0.1:8080
    //
    //        iptables -t nat -C PREROUTING -i wg0 -p tcp --dport 443 -j DNAT --to-destination 127.0.0.1:8443 2>/dev/null || \
    //          iptables -t nat -A PREROUTING -i wg0 -p tcp --dport 443 -j DNAT --to-destination 127.0.0.1:8443
    //      }
    //
    //      del_rules() {
    //        iptables -t nat -D PREROUTING -i wg0 -p tcp --dport 80  -j DNAT --to-destination 127.0.0.1:8080 2>/dev/null || true
    //        iptables -t nat -D PREROUTING -i wg0 -p tcp --dport 443 -j DNAT --to-destination 127.0.0.1:8443 2>/dev/null || true
    //      }
    //
    //      trap del_rules INT TERM
    //
    //      add_rules
    //      # keep task alive; traps handle cleanup
    //      while :; do sleep 3600; done
    //    EOFSH
    //  }
    //
    //  # run it
    //  config {
    //    command = "/bin/sh"
    //    args    = ["local/dnat.sh"]
    //  }
    //
    //  resources {
    //    cpu    = 20
    //    memory = 20
    //  }
    //}
  }
}
