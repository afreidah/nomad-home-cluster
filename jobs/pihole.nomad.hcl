job "pihole" {
  type = "service"

  group "pihole" {
    count = 1
    
    network {
      port "dns" {
        static = 53
      }
      port "http" {
        static = 80
      }
      port "https" {
        static = 443
      }
    }

    service {
      name = "pihole-https"
      port = "https"

      check {
        name     = "pihole-check"
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "pihole-task" {
      driver = "docker"

      env = {
        WEBPASSWORD  = "test"
      }
      config {
        image = "pihole/pihole:latest"
        ports = ["dns", "http", "https"]
        volumes = [
          "dns:/etc/dnsmasq.d",
          #"etc-pihole:/etc/pihole"
        ]
        dns_servers = [
            "127.0.0.1",
            "1.1.1.1",
        ]
      }
    }
  }
}

