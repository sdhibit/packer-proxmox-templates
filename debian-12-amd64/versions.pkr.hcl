packer {
  required_plugins {
    proxmox = {
      version = ">=1.2.1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}
