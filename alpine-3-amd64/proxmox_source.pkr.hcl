source "proxmox" "alpine" {
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
  http_port_min     = var.http_server_port
  http_port_max     = var.http_server_port
  http_interface    = var.http_interface
  vm_interface      = var.vm_interface

  boot = null

  boot_command = [
    "root<enter><wait>",
    "ifconfig eth0 up && udhcpc -i eth0<enter><wait5>", # Start networking with DHCP
    "wget ${local.http_url}/answers<enter><wait>",      #Replace CR if file was generated on Windows machine
    "sed -i 's/\\r$//g' $PWD/answers<enter><wait>",
    "USERANSERFILE=1 setup-alpine -f $PWD/answers<enter><wait5>", # Run alpine installer
    "${local.root_password}<enter><wait>",
    "${local.root_password}<enter><wait>",
    "<wait20>",
    "y<enter><wait20>",
    "reboot<enter>",
    "<wait30>",
    "root<enter>",
    "${local.root_password}<enter><wait>",
    "wget ${local.http_url}/alpine-setup.sh<enter><wait>",
    "chmod +x $PWD/alpine-setup.sh<enter><wait>",
    "sed -i 's/\\r$//g' $PWD/alpine-setup.sh<enter><wait>",
    "$PWD/alpine-setup.sh<enter><wait>",
  ]

  boot_wait = "20s"

  ssh_handshake_attempts    = 100
  ssh_username              = "root"
  ssh_password              = var.ssh_public_key == null ? local.root_password : null
  ssh_private_key_file      = var.ssh_private_key_file
  ssh_clear_authorized_keys = true
  ssh_timeout               = "45m"
  ssh_agent_auth            = var.ssh_agent_auth

  cloud_init              = true
  cloud_init_storage_pool = local.cloud_init_storage_pool
}
