job "deluge" {
  type = "service"

  group "deluge" {
    count = 1
    
    network {
      port "deluge-web" {
        static = 8112
      }
    }

    service {
      name = "deluge-web"
      port = "deluge-web"

      check {
        name     = "deluge-check"
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "deluge-task" {
      driver = "docker"

      env = {
        "PUID" = "1000"
        "PGID" = "1000"
        "SOCKS5_PROXY" = "socks5://vpn:1080"  # The VPN task exposes SOCKS5 proxy on port 1080
      }
      config {
        image = "linuxserver/deluge:latest"
        ports = ["deluge-web"]
      }
    }
  }
}

