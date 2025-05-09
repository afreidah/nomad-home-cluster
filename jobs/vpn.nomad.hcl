job "pia-openvpn" {
  datacenters = ["dc1"]
  type        = "service"

  group "vpn" {
    network {
      mode = "host"
    }

    task "pia" {
      driver = "docker"

      config {
        image = "dperson/openvpn-client"
        network_mode = "host"
        cap_add = ["NET_ADMIN"]
        volumes = [
          "local/pia:/vpn"  # Contains .ovpn file and credentials
        ]
        args = [
          "-f",  # run in foreground
          "-r", "192.168.1.0/24"  # allow LAN routing back in
        ]
      }

      env {
        TZ = "UTC"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}

