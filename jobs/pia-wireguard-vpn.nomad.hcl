###############################################################################
# PIA WireGuard client — Nomad system job
#
# * Requires a dedicated/static IP add‑on from PIA.
# * Uses the thrnz/docker‑wireguard‑pia image (multi‑arch, ARM friendly).
# * Runs in its own network namespace (bridge), so we keep sysctl src_valid_mark.
# * Exposes container HEALTHCHECK via Nomad + an external “what’s my IP” check.
###############################################################################

############################
# Variable declarations
############################
variable "pia_user"   { type = string; nullable = false }
variable "pia_pass"   { type = string; nullable = false }
variable "pia_token"  { type = string; nullable = false }
variable "server_reg" { type = string; nullable = false } 
variable "expect_ip"  { type = string; nullable = false } # 181.214.78.10 

job "pia-wireguard" {
  datacenters = ["dc1"]
  type        = "system"            # run on every client (or constrain with meta/constraint)

  group "wg" {
    restart {
      attempts = 10
      interval = "30m"
      delay    = "30s"
      mode     = "delay"
    }

    task "wireguard" {
      driver = "docker"

      #########################
      # Container configuration
      #########################
      config {
        image = "thrnz/docker-wireguard-pia:latest"
        network_mode = "host"

        # needs NET_ADMIN to create wg0
        cap_add = ["NET_ADMIN"]

        # Persist config + forwarded port on the host
        volumes = [
          "/opt/wireguard:/pia"     # create this dir on host first
        ]
      }

      #########################
      # Environment variables
      #########################
      env {
        VPN_ENDPOINT_PORT            = 1337
        PIA_INTERFACE                = "wg0"
        PIA_DNS                      = "true"
        PIA_DNS                      = "true"
        PORT_FORWARDING              = "true"
        PORT_FORWARDING              = "true"
        LOC                          = "ca_vancouver" 
        VPN_ENDPOINT_IP              = "181.214.78.10"
        LOCAL_NETWORK                = "192.168.1.0/24"
        PASS                         = "${var.pia_pass}"
        USER                         = "${var.pia_user}"
        PIA_TOKEN                    = "${var.pia_token}"
        PORT_FILE                    = "/pia-shared/port.dat"
        VPN_PORT_FORWARDING_PROVIDER = "private internet access"
      }

      resources {
        cpu    = 100     # 0.1 vCPU
        memory = 64      # MiB
      }
    }

    # ------------------------------------------------------------------
    # Dummy service so Consul shows health; one script check attached
    # ------------------------------------------------------------------
    service {
      name = "wireguard"

      #########################
      # External reachability check
      #########################
      check {
        name     = "static-ip-match"
        type     = "script"
        task     = "wireguard" 
        command  = "/bin/sh"
        args     = ["-c", "curl -s --max-time 5 https://ipinfo.io/ip | grep -q 181.214.78.10"]
        interval = "60s"
        timeout  = "10s"
      }
    }
  }
}

