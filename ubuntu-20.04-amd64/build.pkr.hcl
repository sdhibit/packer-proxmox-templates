build {
  sources = [
    "source.file.meta_data",
    "source.file.user_data",
    "source.proxmox.ubuntu"
  ]

  provisioner "shell" {
    inline = ["while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"]
  }

  provisioner "shell" {
    execute_command = "sudo /bin/sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "if [ -f /etc/cloud/cloud.cfg.d/99-installer.cfg ]; then rm /etc/cloud/cloud.cfg.d/99-installer.cfg; echo 'Deleting subiquity cloud-init config'; fi"
    ]
  }


  # provisioner "shell" {
  #   environment_vars = [
  #     "USERNAME=${local.ssh_username}"
  #   ]
  #   skip_clean      = true
  #   execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} {{ .Path }} ; rm -f {{ .Path }}"
  #   inline_shebang = "/bin/bash -e"
  #   inline = [
  #     "rm -f /etc/sudoers.d/90-cloud-init-users",
  #     #"deluser --remove-home $USERNAME",
  #   ]

  # }

}
