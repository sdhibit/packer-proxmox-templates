packer {
  required_plugins {
    proxmox = {
      version = ">=1.1.0"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}
