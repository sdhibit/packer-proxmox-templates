packer {
  required_plugins {
    proxmox = {
      version = ">=1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}
