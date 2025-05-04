# =============================
# Nomad Server Config
# =============================

bind_addr = "192.168.1.160"

data_dir = "/opt/nomad"

# ⬇️ On Linux (Raspberry Pi), change "en0" to "eth0"
advertise {
  http = "{{ GetInterfaceIP \"en0\" }}"
  rpc  = "{{ GetInterfaceIP \"en0\" }}"
  serf = "{{ GetInterfaceIP \"en0\" }}"
}

server {
  enabled          = true
  bootstrap_expect = 1
  raft_multiplier  = 2
}


# Enable the Docker plugin with privileged containers (optional)
plugin "docker" {
  config {
    allow_privileged = true
  }
}
