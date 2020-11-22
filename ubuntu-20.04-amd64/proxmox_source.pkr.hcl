source "proxmox" "ubuntu" {
  proxmox_url               = "https://${var.proxmox_host}:${var.proxmox_port}/api2/json"
  node                      = var.proxmox_node
  username                  = var.proxmox_username
  password                  = var.proxmox_password
  insecure_skip_tls_verify  = var.proxmox_skip_verify_tls

  template_name          = var.template_name
  template_description   = var.template_description
  vm_id                  = var.template_vm_id

  iso_url           = local.use_iso_file ? null : var.iso_url
  iso_storage_pool  = var.iso_storage_pool
  iso_file          = local.use_iso_file? "${var.iso_storage_pool}:iso/${var.iso_file}" : null
  iso_checksum      = var.iso_checksum
  unmount_iso       = true

  os          = "l26" 
  qemu_agent  = true
  memory      = var.memory
  cores       = var.cores
  sockets     = var.sockets

  scsi_controller = "virtio-scsi-pci"

  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
  }

  disks {
    disk_size         = "20G"
    storage_pool      = "local-lvm"
    storage_pool_type = "lvm"
    type              = "scsi"
  }

  http_directory           = "http"
  http_bind_address        = var.http_bind_address
  http_interface           = var.http_interface
  vm_interface             = var.vm_interface

  boot         = null // "order=scsi0;ide2",
  boot_command = [
    "<esc><wait><esc><wait><f6><wait><esc><wait>", 
    "<bs><bs><bs><bs><bs>", 
    "autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ", 
    "--- <enter>"
  ]
  boot_wait    = "5s"
    
  ssh_handshake_attempts    = 100
  ssh_username              = local.ssh_username
  ssh_password              = local.ssh_password
  ssh_private_key_file      = local.ssh_private_key_file
  ssh_clear_authorized_keys = true
  ssh_timeout               = "45m"
  ssh_agent_auth            = var.ssh_agent_auth

  cloud_init              = var.cloud_init
  cloud_init_storage_pool = var.cloud_init_storage_pool

}