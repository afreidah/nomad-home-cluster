# =============================
# Nomad Client Config
# =============================

bind_addr = "0.0.0.0"

data_dir = "/opt/nomad"

# ⬇️ On Linux (Raspberry Pi), change "en0" to "eth0"
advertise {
  http = "{{ GetInterfaceIP \"en0\" }}"
  rpc  = "{{ GetInterfaceIP \"en0\" }}"
  serf = "{{ GetInterfaceIP \"en0\" }}"
}

client {
  enabled = true
  servers = ["127.0.0.1:4647"]
}

# 🔌 Enable Consul integration
consul {
  address          = "127.0.0.1:8500"
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

