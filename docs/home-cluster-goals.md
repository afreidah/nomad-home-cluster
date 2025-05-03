# 🏠 Home Cluster Project - High-Level Goals

## 📦 Cluster Infrastructure
- **Nodes**: 3–5 Raspberry Pi devices forming a Nomad cluster.
- **Orchestration**: HashiCorp Nomad to manage services and deployments.
- **Service Discovery**: HashiCorp Consul for automatic registration and inter-service communication.
- **Routing & Proxying**: Traefik to auto-generate URL endpoints for services.
- **Shared Storage**: Set up shared network storage (e.g. NFS or Samba) across the cluster for persistent volumes.

## 🌐 Network & Traffic Management
- **VPN Integration**:
  - Use a VPN (e.g. Private Internet Access) to route **specific service traffic** (e.g. Deluge).
  - Avoid routing all cluster or home network traffic through VPN for simplicity.
- **Pi-hole DNS**:
  - Run Pi-hole as a service in Nomad.
  - Set it as the default DNS for all devices on the home network to block ads and trackers.

## 🧩 Service Architecture
- **Deluge + VPN**:
  - Run Deluge torrent client as a Nomad job.
  - Route its traffic **only** through a VPN client container (OpenVPN).
- **Pi-hole**:
  - Exposed on the local network.
  - Acts as the network-wide DNS sinkhole.
- **Media Server/Center**:
  - Web interface for managing and streaming media.
  - Compatibility with Roku and Apple TV.
- **Tor Proxy**:
  - Optional routing of traffic through Tor for privacy/anonymity.
  - Isolated or service-specific depending on needs.

## 🌍 External Access
- Use your own domain name in combination with:
  - Static IPs provided by your VPN, or
  - Dynamic DNS, to expose selected services outside the home.
- Traefik + Consul integration to auto-generate URLs and TLS certs (optional).

## 🧪 Local Development Goals (Current Phase)
- Develop and test job files locally on a single machine.
- Experiment with:
  - VPN task isolation.
  - Volume mounting for configuration.
  - Consul integration.
  - Traefik setup for auto-routing.
