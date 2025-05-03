job "pia-vpn" {
  datacenters = ["dc1"]

  group "vpn" {
    task "openvpn" {
      driver = "docker"

      config {
        image        = "dperson/openvpn-client"
        network_mode = "host"  # Use host's network stack directly
        command      = "openvpn"
        args = [
          "--config", "/vpn/us_california.ovpn",
          "--auth-user-pass", "/vpn/pia_credentials.txt"
        ]
      }

      # Define volume mount
      volumes = [
        "/Users/alexfreidah/tools/nomad-homelap-repo/vpn:/vpn"
      ]

      resources {
        cpu    = 100
        memory = 128
      }

      restart {
        attempts = 10
        interval = "5m"
        delay    = "10s"
        mode     = "delay"
      }
    }
  }
}

