job "pihole" {
  datacenters = ["dc1"]
  type        = "service"

  group "pihole" {
    count = 1

    network {
      mode = "host"

      port "dns" {
        static = 53
      }

      port "dhcp" {
        static = 57
      }

      port "http" {
        static      = 80
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
        "traefik.http.routers.pihole.entrypoints=",
        "traefik.http.routers.pihole.middlewares=pihole-stripprefix",
        "traefik.http.middlewares.pihole-stripprefix.stripprefix.prefixes=/admin",
        "traefik.http.services.pihole.loadbalancer.server.port=80"
      ]

      check {
        name     = "pihole-http"
        type     = "http"
        path     = "/admin/"
        interval = "10s"
        timeout  = "2s"
        port     = "http"
      }
    }

    task "pihole-task" {
      driver = "docker"

      template {
        data = <<EOF
# /opt/pihole/02-custom.conf
# Explicitly allow requests from LAN
server=/consul/192.168.1.225#8600
# server=192.168.1.225#5335
bind-interfaces
listen-address=0.0.0.0
allow-address=0.0.0.0
EOF
        destination = "local/dnsmasq.conf"
        change_mode = "restart"
      }

      config {
        image        = "pihole/pihole:latest"
        ports        = ["dns", "http", "https", "dhcp"]
        privileged   = true
        dns_servers  = ["8.8.8.8", "1.1.1.1"]

        volumes = [
          "/opt/nomad/data/pihole:/etc/pihole",
          "local/dnsmasq.conf:/etc/dnsmasq.d/02-pihole-custom.conf",
        ]
      }
      
      env = {
        PIHOLE_DNSMASQ_LISTENING = "all"
        PIHOLE_DNS_1 = "unbound.service.consul#5335"
        PIHOLE_DNS_2 = "192.168.1.225"
        TZ = "America/Los_Angeles"
        WEB_PORT = "80"
        FTLCONF_webserver_api_password = "test"
        VIRTUAL_HOST = "0.0.0.0"
      }

      resources {
        cpu    = 150
        memory = 128
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
