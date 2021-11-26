source "proxmox" "alpine" {
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
    bridge = local.network_bridge
  }

  disks {
    disk_size         = "512M"
    storage_pool      = local.disk_storage_pool
    storage_pool_type = local.disk_storage_pool_type
    type              = "scsi"
  }

  http_directory           = "http"
  http_bind_address        = var.http_bind_address
  http_port_min            = var.http_server_port
  http_port_max            = var.http_server_port
  http_interface           = var.http_interface
  vm_interface             = var.vm_interface

  boot         = null // "order=scsi0;ide2",
  boot_command = [
    "root<enter><wait>",
    "ifconfig eth0 up && udhcpc -i eth0<enter><wait5>",
    "wget ${ local.http_url }/answers && sed -i 's/\\r$//g' $PWD/answers<enter><wait>", #Replace CR if file was generated on Windows machine
    "setup-alpine -f $PWD/answers<enter><wait5>",
    "${ local.root_password }<enter><wait>",
    "${ local.root_password }<enter><wait>",
    "<wait20>",
    "y<enter><wait20>",
    "mount /dev/sda3 /mnt<enter>", # TODO: change to variable if LVM is set: /dev/vg0/lv_root
    "mount /dev/ /mnt/dev/ --bind <enter>",
    "mount -t proc none /mnt/proc <enter>",
    "mount -o bind /sys /mnt/sys <enter>",
    "chroot /mnt /bin/sh -l <enter><wait>",
    "sed -r -i '\\|/v[0-9]+\\.[0-9]+/community|s|^#||g' /etc/apk/repositories <enter><wait>",
    "echo -e 'nameserver 1.1.1.1' > /etc/resolv.conf <enter><wait>",
    "apk update <enter><wait10>",
    "apk add sudo <enter><wait>",
    "apk add openssh-server-pam <enter><wait>",
    "echo 'UsePAM yes' >> /etc/ssh/sshd_config <enter><wait>",
    "apk add 'qemu-guest-agent' <enter><wait>",
    "apk add 'partx' 'ifupdown-ng' 'iproute2-minimal' 'cloud-init' <enter><wait>",
    "echo -e GA_PATH=\"/dev/vport2p1\" >> /etc/conf.d/qemu-guest-agent <enter><wait>", # ls /dev/vport*
    "rc-update add qemu-guest-agent<enter><wait>",
    "setup-cloud-init <enter><wait>",    
    "echo 'datasource_list: [ NoCloud, ConfigDrive, None ]' > /etc/cloud/cloud.cfg.d/99_pve.cfg <enter><wait>",
    "mkdir -p /var/lib/cloud/seed/nocloud-net <enter><wait>",
    "wget -P /var/lib/cloud/seed/nocloud-net ${ local.http_url }/meta-data && sed -i 's/\\r$//g' /var/lib/cloud/seed/nocloud-net/meta-data <enter><wait>",
    "wget -P /var/lib/cloud/seed/nocloud-net ${ local.http_url }/user-data && sed -i 's/\\r$//g' /var/lib/cloud/seed/nocloud-net/user-data <enter><wait>",
    "echo 'isofs' > /etc/modules-load.d/isofs.conf && chmod -x /etc/modules-load.d/isofs.conf <enter><wait>", # Add iso9660 as a valid filesystem. Necessary for cloud-init to mount NoData with proxmox cloud-init drive (/dev/sr[0-9]).
    "exit <enter><wait>",
    "umount /mnt/sys <enter><wait>",
    "umount /mnt/proc <enter><wait>",
    "umount /mnt/dev <enter><wait>",
    "umount /mnt <enter>",
    "reboot <enter>",
  ]

  boot_wait    = "20s"
    
  ssh_handshake_attempts    = 100
  ssh_username              = local.ssh_username
  ssh_password              = local.ssh_password
  ssh_private_key_file      = local.ssh_private_key_file
  ssh_clear_authorized_keys = true
  ssh_timeout               = "20m"
  ssh_agent_auth            = var.ssh_agent_auth

  cloud_init              = true
  // latest proxmox API requires this to be set in order for a cloud init image to be created. 
  // Does not take boot disk storage pool as a default anymore. 
  cloud_init_storage_pool = local.cloud_init_storage_pool

}