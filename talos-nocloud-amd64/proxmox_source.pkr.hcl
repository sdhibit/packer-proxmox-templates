source "proxmox-iso" "talos" {
  proxmox_url              = "https://${var.proxmox_host}:${var.proxmox_port}/api2/json"
  node                     = var.proxmox_node
  username                 = var.proxmox_username
  password                 = var.proxmox_password
  insecure_skip_tls_verify = var.proxmox_skip_verify_tls

  template_name        = coalesce(var.template_name, local.template_name)
  template_description = coalesce(var.template_description, local.template_description)
  vm_id                = var.template_vm_id

  iso_url          = local.use_iso_file ? null : var.boot_iso_url
  iso_storage_pool = var.boot_iso_storage_pool
  iso_file         = local.use_iso_file ? "${var.boot_iso_storage_pool}:iso/${var.boot_iso_file}" : null
  iso_checksum     = var.boot_iso_checksum
  #iso_download_pve = true
  unmount_iso = true

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
    disk_size    = var.disk_size
    storage_pool = var.disk_storage_pool
    format       = var.disk_format
    type         = var.disk_type
  }

  http_directory    = "http"
  http_bind_address = var.http_bind_address
  http_interface    = var.http_interface
  http_port_min     = var.http_server_port
  http_port_max     = var.http_server_port

  vm_interface = var.vm_interface

  boot      = null // "order=scsi0;ide2",
  boot_wait = "30s"
  boot_command = [
    "root<enter><wait>",
    "passwd<enter>${var.ssh_password}<enter>${var.ssh_password}<enter><wait>",
    "ifconfig eth0 up && udhcpc -i eth0<enter><wait5>", # Start networking with DHCP
    "setup-apkrepos -1 -c<enter><wait5>",
    "apk update<enter><wait>",
    "apk add ca-certificates curl openssh qemu-guest-agent<enter><wait>",
    "curl -L ${local.http_url}/schematic.yaml -o /tmp/schematic.yaml<enter><wait>",
    "sed -r -i 's/^#?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config<enter><wait>",
    "sed -r -i 's/^#?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config<enter><wait>",
    "echo -e GA_PATH=\"${local.ga_path}\" >> /etc/conf.d/qemu-guest-agent<enter><wait>",
    "rc-service qemu-guest-agent restart<enter><wait>",
    "rc-service sshd restart<enter><wait>",
  ]

  // rc-service sshd stop

  // # Set script variables from packer
  // SSH_PUBLIC_KEY="ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAFY8rg0/PYGCS3aHtNriO0Pb6nAAXPVTQg4gbO8w8APx0JIRWKbnAWoTef/femIAjYZWflYDvfGNzDjQ34ZRPhoigF5c4LdAUMB9NSCHYke+hNS1HHSpXvdg6ZEMfrDUalTzGq9yovmVA3C912lwWbiptpfd7NN6jGgihYVmdzroILTgg== admin@apollo"
  // USE_PUBLIC_KEY_AUTH="true"
  // USE_OPENSSH_PAM="true"

  // # Update apk repositories
  // sed -r -i '\|/v[0-9]+\.[0-9]+/community|s|^#\s?||g' /etc/apk/repositories
  // apk update

  // # Add qemu-guest-agent
  // apk add qemu-guest-agent
  // echo -e GA_PATH="/dev/vport2p1" >> /etc/conf.d/qemu-guest-agent
  // rc-update add qemu-guest-agent
  // rc-service qemu-guest-agent restart



  // # Add root user authorized_keys
  // if [ "$USE_PUBLIC_KEY_AUTH" = "true" ]
  // then
  //   mkdir ~/.ssh
  //   chmod 700 ~/.ssh
  //   echo $SSH_PUBLIC_KEY >> ~/.ssh/authorized_keys
  //   chmod 600 ~/.ssh/authorized_keys
  // fi

  // # Update ssh configuration
  // if [ "$USE_PUBLIC_KEY_AUTH" = "true" ]
  // then
  //   sed -r -i "s/^#?PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
  //   sed -r -i "s/^#?PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config
  //   sed -r -i "s/^#?PermitRootLogin.*/PermitRootLogin prohibit-password/g" /etc/ssh/sshd_config
  // else
  //   sed -r -i "s/^#?PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
  //   sed -r -i "s/^#?PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
  // fi

  // # Use PAM version of openssh
  // if [ "$USE_OPENSSH_PAM" = "true" ]
  // then
  //   apk add openssh-server-pam
  //   rm /usr/sbin/sshd
  //   ln -s /usr/sbin/sshd.pam /usr/sbin/sshd
  //   sed -r -i "s/^#?UsePAM.*/UsePAM yes/g" /etc/ssh/sshd_config
  // fi

  // apk add make jq

  // rc-service sshd restart

  // communicator = "none"

  #shutdown_command = ""
  #shutdown_command = "sudo poweroff"
  ssh_handshake_attempts = 100
  ssh_username           = "root"
  ssh_password           = var.ssh_password
  // ssh_private_key_file      = var.ssh_private_key_file
  ssh_clear_authorized_keys = true
  ssh_timeout               = "10m"
  // ssh_agent_auth            = var.ssh_agent_auth

  cloud_init              = true
  cloud_init_storage_pool = local.cloud_init_storage_pool


  // "<enter><wait30>",
  // "tce-load -wi openssh<enter><wait>",
  // "passwd <<EOF<enter>${var.ssh_password}<enter>${var.ssh_password}<enter>EOF<enter>",
  // "sudo cp /usr/local/etc/ssh/sshd_config.orig /usr/local/etc/ssh/sshd_config<enter>",
  // "sudo /usr/local/etc/init.d/openssh start<enter>",
  // "tce-load -wi ca-certificates curl jq xz<enter><wait10>",
  // "curl -L ${local.http_url}/schematic.yaml -o /tmp/schematic.yaml<enter><wait>",
  // "curl -X POST --data-binary @/tmp/schematic.yaml ${local.talos_factory_url}/schematics<enter><wait>",
  // "curl -L ${local.talos_factory_url}/image/14e9b0100f05654bedf19b92313cdc224cbff52879193d24f3741f1da4a3cbb1/${var.talos_version}/nocloud-amd64.raw.xz -o /tmp/talos.raw.xz<enter><wait>",
  //   // "wget ${local.http_url}/answers<enter><wait>",      #Replace CR if file was generated on Windows machine
  //   // "curl -L ${local.talos_image} -o /tmp/talos.raw.xz",
  //   // "xz -d -c /tmp/talos.raw.xz | dd of=/dev/sda && sync",
  // // "tce-load -wi openssh<enter>",
  // // "passwd <<EOF<enter>${var.ssh_password}<enter>${var.ssh_password}<enter>EOF<enter>",
  // // "sudo cp /usr/local/etc/ssh/sshd_config.orig /usr/local/etc/ssh/sshd_config<enter>",
  // // "sudo /usr/local/etc/init.d/openssh start<enter>",
  // "sudo poweroff<enter>",

}
