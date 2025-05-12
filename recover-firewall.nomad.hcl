job "recover-firewall" {
  datacenters = ["dc1"]
  type        = "batch"

  group "fix" {
    task "flush-iptables" {
      driver = "docker"

      config {
        image        = "alpine:3.18"
        network_mode = "host"           # operate on host network namespace
        cap_add      = ["NET_ADMIN"]    # allow iptables manipulation
        command      = "/bin/sh"
        args         = ["-c",
          "iptables -F && iptables -t nat -F && iptables -X && echo 'Flushed all iptables rules'"]
      }

      resources {
        cpu    = 50
        memory = 32
      }

      # don’t restart; we just want it once
      restart {
        attempts = 0
      }
    }
  }
}

