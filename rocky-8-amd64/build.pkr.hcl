build {

  sources = [
    "source.file.kickstart",
    "source.proxmox.rocky"
  ]

  # Packages
  provisioner "shell" {
    execute_command = "sudo /bin/sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "yum update -y",
      "yum install -y cloud-init cloud-utils-growpart gdisk",
      "yum clean all",
    ]
  }

  # Add supported cloud-init datasources for Proxmox
  provisioner "file" {
    content     = <<-EOF
    datasource_list: [ NoCloud, ConfigDrive ]
    EOF
    destination = "/tmp/99_pve.cfg"
  }

  provisioner "shell" {
    execute_command = "sudo /bin/sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "mv /tmp/99_pve.cfg /etc/cloud/cloud.cfg.d/99_pve.cfg",
      "chown root:root /etc/cloud/cloud.cfg.d/99_pve.cfg",
      "chmod 644 /etc/cloud/cloud.cfg.d/99_pve.cfg"
    ]
  }

  # Cleanup
  provisioner "shell" {
    execute_command = "sudo /bin/sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "shred -u /etc/ssh/*_key /etc/ssh/*_key.pub",
      "unset HISTFILE; rm -rf /home/*/.*history /root/.*history",
      "rm -f /root/*ks.cfg",
      "passwd -d root",
      "passwd -l root",
    ]
  }

  # Disable packer provisioner access
  provisioner "shell" {
    environment_vars = [
      "SSH_USERNAME=${var.ssh_username}"
    ]
    skip_clean      = true
    execute_command = "sudo /bin/sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "passwd -d $SSH_USERNAME",
      "passwd -l $SSH_USERNAME",
      "rm -rf /home/$SSH_USERNAME/.ssh/authorized_keys",
      "rm -rf /etc/sudoers.d/packer",
    ]
  }

}
