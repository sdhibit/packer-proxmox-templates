build {
  sources = [
    "source.file.configuration",
    "source.file.users",
    "source.proxmox-iso.nixos",
  ]

  # clean cloud-init
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} {{ .Path }};"
    inline = [
      "cloud-init clean"
    ]
  }

  # Packages & Configuration
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} {{ .Path }};"
    inline = [
      "nix-collect-garbage -d"
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
