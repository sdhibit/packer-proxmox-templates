packer {
  required_plugins {
    proxmox = {
      version = "~> 1.2.4"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}
