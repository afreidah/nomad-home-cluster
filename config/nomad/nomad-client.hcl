# =============================
# Nomad Client Config (macOS)
# =============================

data_dir = "/opt/nomad"

advertise {
  http = "{{ GetInterfaceIP \"en0\" }}"
  rpc  = "{{ GetInterfaceIP \"en0\" }}"
  serf = "{{ GetInterfaceIP \"en0\" }}"
}

client {
  enabled   = true
  servers   = ["192.168.1.160:4647"]
  cni_path  = "/opt/cni/bin"

  host_volume "dnsmasq_config" {
    path      = "/opt/nomad/config/dnsmasq_config"
    read_only = false
  }

  host_volume "pihole_data" {
    path      = "/opt/nomad/data/pihole"
    read_only = false
  }

  host_volume "traefik_data" {
    path      = "/opt/nomad/data/traefik"
    read_only = false
  }

  host_volume "unbound_data" {
    path      = "/opt/nomad/data/unbound"
    read_only = false
  }
}

consul {
  address          = "192.168.1.160:8500"
  auto_advertise   = true
  client_auto_join = true
}

plugin "docker" {
  config {
    allow_privileged = true
  }
}

