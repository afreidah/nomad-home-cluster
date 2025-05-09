# =============================
# Nomad Server Config (macOS)
# =============================

bind_addr = "192.168.1.160"
data_dir  = "/opt/nomad"

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

plugin "docker" {
  config {
    allow_privileged = true
  }
}
