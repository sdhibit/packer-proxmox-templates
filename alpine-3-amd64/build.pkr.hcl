build {
  sources = [
    "source.file.answers",
    "source.file.setup",
    "source.proxmox.alpine",
  ]

  # Packages
  provisioner "shell" {
    execute_command = "/bin/sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "apk update",
      "apk add --no-cache sudo python3",
      "apk add --no-cache cloud-init cloud-utils-growpart e2fsprogs-extra",
    ]
  }

  # Cloud-Init
  provisioner "shell" {
    execute_command = "/bin/sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      # Add iso9660 as a valid filesystem. Necessary for cloud-init to mount NoData with proxmox cloud-init drive (/dev/sr[0-9]).
      "echo 'isofs' > /etc/modules-load.d/isofs.conf",
      "chmod -x /etc/modules-load.d/isofs.conf",
      "setup-cloud-init",
      "echo 'datasource_list: [ NoCloud, ConfigDrive, None ]' > /etc/cloud/cloud.cfg.d/99_pve.cfg",
      "chmod 644 /etc/cloud/cloud.cfg.d/99_pve.cfg",
    ]
  }

  # Cleanup
  provisioner "shell" {
    execute_command = "/bin/sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "shred -u /etc/ssh/*_key /etc/ssh/*_key.pub", # remove host keys
      "unset HISTFILE; rm -rf /root/.*history",     # remove command history
      "rm -f /root/alpine-setup.sh",                # remove setup script
      "rm -f /root/.ssh/authorized_keys",
      "sed -r -i 's/^#?PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config",
      "sed -r -i 's/^#?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config",
      "passwd -d root", # Disable root access
      "passwd -l root", # Lock root password
    ]
  }

}
