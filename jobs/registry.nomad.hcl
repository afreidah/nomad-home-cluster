job "registry" {
  datacenters = ["dc1"]
  type        = "service"

  group "registry" {
    count = 1

    network {
      port "http" {
        static = 5000
      }
    }

    volume "registry_data" {
      type      = "host"
      source    = "registry_data"
      read_only = false
    }

    service {
      name     = "registry"
      port     = "http"
      provider = "consul"

      tags = [
        "docker-registry"
      ]

      check {
        name     = "http-check"
        type     = "http"
        path     = "/v2/"
        interval = "10s"
        timeout  = "2s"
        port     = "http"
      }
    }

    task "registry" {
      driver = "docker"
    
      config {
        image = "registry:2"
        ports = ["http"]
      }
    
      volume_mount {
        volume      = "registry_data"
        destination = "/var/lib/registry"
        read_only   = false
      }
    
      logs {
        max_files     = 1
        max_file_size = 10
      }
    
      restart {
        attempts = 3
        interval = "5m"
        delay    = "15s"
        mode     = "fail"
      }
    
      env {
        REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY = "/var/lib/registry"
      }
    }
  }
}

