build {
  sources = [
    "source.file.meta_data",
    "source.file.user_data",
    "source.proxmox.ubuntu"
  ]

  # Wait for cloud-init to complete after reboot
  provisioner "shell" {
    inline = ["while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"]
  }

  # Clean up subiquity installer
  provisioner "shell" {
    execute_command = "sudo /bin/sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "if [ -f /etc/cloud/cloud.cfg.d/99-installer.cfg ]; then rm /etc/cloud/cloud.cfg.d/99-installer.cfg; echo 'Deleting subiquity cloud-init config'; fi",
      "if [ -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg ]; then rm /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg; echo 'Deleting subiquity cloud-init network config'; fi"
    ]
  }

  # Disable packer provisioner access
  provisioner "shell" {
    environment_vars = [
      "SSH_USERNAME=${var.ssh_username}"
    ]
    skip_clean      = true
    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} {{ .Path }}; rm -f {{ .Path }}"
    inline = [
      "passwd -d $SSH_USERNAME",
      "passwd -l $SSH_USERNAME",
      "rm -rf /home/$SSH_USERNAME/.ssh/authorized_keys",
      "rm -f /etc/sudoers.d/90-cloud-init-users",
    ]
  }

}
