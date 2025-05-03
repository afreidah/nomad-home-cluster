# =============================
# Consul Server Config
# =============================

server = true
bootstrap_expect = 1
datacenter = "dc1"
data_dir = "/opt/consul"
bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"

# ⬇️ On Linux (Raspberry Pi), change "en0" to "eth0"
advertise_addr = "{{ GetInterfaceIP \"en0\" }}"

ui_config {
  enabled = true
}

connect {
  enabled = true
}
