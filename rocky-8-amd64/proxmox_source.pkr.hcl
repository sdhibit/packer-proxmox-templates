source "proxmox" "rocky" {
  proxmox_url              = "https://${var.proxmox_host}:${var.proxmox_port}/api2/json"
  node                     = var.proxmox_node
  username                 = var.proxmox_username
  password                 = var.proxmox_password
  insecure_skip_tls_verify = var.proxmox_skip_verify_tls

  template_name        = var.template_name
  template_description = var.template_description
  vm_id                = var.template_vm_id

  iso_url          = local.use_iso_file ? null : var.iso_url
  iso_storage_pool = var.iso_storage_pool
  iso_file         = local.use_iso_file ? "${var.iso_storage_pool}:iso/${var.iso_file}" : null
  iso_checksum     = var.iso_checksum
  unmount_iso      = true

  os         = "l26"
  qemu_agent = true
  memory     = var.memory
  cores      = var.cores
  sockets    = var.sockets

  scsi_controller = "virtio-scsi-pci"

  network_adapters {
    model  = "virtio"
    bridge = var.network_bridge
  }

  disks {
    disk_size         = var.disk_size
    storage_pool      = var.disk_storage_pool
    storage_pool_type = var.disk_storage_pool_type
    format            = var.disk_format
    type              = var.disk_type
  }

  http_directory    = "http"
  http_bind_address = var.http_bind_address
  http_interface    = var.http_interface
  http_port_min     = var.http_server_port
  http_port_max     = var.http_server_port
  vm_interface      = var.vm_interface

  boot         = null
  boot_command = ["<tab> text inst.ks=${local.http_url}/ks.cfg<enter><wait>"]
  boot_wait    = "5s"

  ssh_handshake_attempts    = 100
  ssh_username              = var.ssh_username
  ssh_password              = var.ssh_password
  ssh_private_key_file      = var.ssh_private_key_file
  ssh_clear_authorized_keys = true
  ssh_timeout               = "45m"
  ssh_agent_auth            = var.ssh_agent_auth

  cloud_init = true
  // latest proxmox API requires this to be set in order for a cloud init image to be created.
  // Does not take boot disk storage pool as a default anymore.
  cloud_init_storage_pool = local.cloud_init_storage_pool

}
