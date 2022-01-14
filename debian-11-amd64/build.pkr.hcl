build {
  sources = [
    "source.file.preseed",
    "source.proxmox.debian",
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
      "unset HISTFILE; rm -rf /home/*/.*history /root/.*history",
      "passwd -d $SSH_USERNAME",
      "passwd -l $SSH_USERNAME",
      "rm -rf /home/$SSH_USERNAME/.ssh/authorized_keys",
      "rm -rf /etc/sudoers.d/packer",
    ]
  }

}
