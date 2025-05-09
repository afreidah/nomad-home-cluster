job "pia-vpn" {
  datacenters = ["dc1"]
  type = "service"

  group "vpn" {
    count = 1

    network {
      mode = "bridge"
    }

    task "pia" {
      driver = "docker"

      config {
        image = "qmcgaw/gluetun:latest"
        ports = []
        network_mode = "bridge"

        env = {
          VPN_SERVICE_PROVIDER = "pia"
          VPN_TYPE             = "openvpn"
          PIA_USER             = "your_pia_username"
          PIA_PASSWORD         = "your_pia_password"
          REGION               = "us_chicago" # or any supported PIA region
        }

        cap_add = ["NET_ADMIN"] # needed for routing
      }

      resources {
        cpu    = 100
        memory = 128
      }

      volume_mount {
        volume      = "secrets"
        destination = "/gluetun"
        read_only   = true
      }

      template {
        destination = "secrets/.env"
        env         = true
        data        = <<EOT
PIA_USER="your_pia_username"
PIA_PASSWORD="your_pia_password"
EOT
      }
    }
  }
}
