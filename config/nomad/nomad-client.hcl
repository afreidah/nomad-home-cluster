# =============================
# Nomad Client Config
# =============================

data_dir = "/opt/nomad"

# ⬇️ On Linux (Raspberry Pi), change "en0" to "eth0"
advertise {
  http = "{{ GetInterfaceIP \"en0\" }}"
  rpc  = "{{ GetInterfaceIP \"en0\" }}"
  serf = "{{ GetInterfaceIP \"en0\" }}"
}

client {
  enabled = true
  servers = ["192.168.1.160:4647"]
  cni_path = "/opt/cni/bin"
}

# 🔌 Enable Consul integration
consul {
  address          = "192.168.1.160:8500"
  auto_advertise   = true
  client_auto_join = true
}

plugin "docker" {
  config {
    allow_privileged = true
    volumes {
      enabled = true
    }
  }
}

plugin "cni" {
  config {
    bin_dir  = "/opt/cni/bin"
    conf_dir = "/etc/cni/net.d"
  }
}
