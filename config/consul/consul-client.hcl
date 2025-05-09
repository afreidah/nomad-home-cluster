# =============================
# Consul Client Config
# =============================

server = false
data_dir = "/opt/consul"
bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"

# ⬇️ On Linux (Raspberry Pi), change "en0" to "eth0"
advertise_addr = "{{ GetInterfaceIP \"en0\" }}"

retry_join = ["127.0.0.1"]

connect {
  enabled = true
}
