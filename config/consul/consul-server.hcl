# =============================
# Consul Server Config
# =============================

server = true
bootstrap_expect = 1
bind_addr = "192.168.1.160"
advertise_addr = "192.168.1.160"
client_addr = "0.0.0.0"
data_dir = "/opt/consul"
ui = true

# ⬇️ On Linux (Raspberry Pi), change "en0" to "eth0"
advertise_addr = "{{ GetInterfaceIP \"en0\" }}"

ui_config {
  enabled = true
}

connect {
  enabled = true
}

recursors = ["8.8.8.8"]         # fallback for non-.consul names
ports {
  dns = 8600
}
