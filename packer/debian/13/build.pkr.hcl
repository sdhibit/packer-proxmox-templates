build {
  sources = [
    "source.file.preseed",
    "source.proxmox-iso.debian",
  ]

  # Packages & Configuration
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} {{ .Path }};"
    inline = [
      "apt-get update",
      "apt-get install -y cloud-init cloud-guest-utils",
      "echo 'datasource_list: [ NoCloud, ConfigDrive, None ]' > /etc/cloud/cloud.cfg.d/99_pve.cfg",
      "chmod 644 /etc/cloud/cloud.cfg.d/99_pve.cfg",
      "apt-get clean -y",
    ]
  }

  # Cleanup & Disable packer provisioner access
  provisioner "shell" {
    environment_vars = [
      "SSH_USERNAME=${var.ssh_username}"
    ]
    skip_clean      = true
    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} {{ .Path }}; rm -f {{ .Path }}"
    inline = [
      "shred -u /etc/ssh/*_key /etc/ssh/*_key.pub",
      # Truncate, don't delete - systemd regenerates an empty machine-id on first boot
      # but not a missing one, and clones sharing an ID collide on DHCP and journald.
      "truncate -s 0 /etc/machine-id",
      "rm -f /var/lib/dbus/machine-id",
      "ln -s /etc/machine-id /var/lib/dbus/machine-id",
      # Clear cloud-init state so the clone's first boot is a real first boot.
      "rm -rf /var/lib/cloud/*",
      "unset HISTFILE; rm -rf /home/*/.*history /root/.*history",
      "passwd -d $SSH_USERNAME",
      "passwd -l $SSH_USERNAME",
      "rm -rf /home/$SSH_USERNAME/.ssh/authorized_keys",
      "rm -rf /etc/sudoers.d/packer",
    ]
  }

}
