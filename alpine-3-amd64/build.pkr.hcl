build {
  sources = [
    "source.file.answers",
    "source.file.meta_data",
    "source.file.user_data",
    "source.proxmox.alpine",
  ]

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
    ]
  }

  provisioner "shell" {
    execute_command = "sudo /bin/sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "rm -f /etc/sudoers.d/90-cloud-init-users",
      "rm -rf /var/lib/cloud/seed; echo 'Deleting original cloud-init seed files'",
      "cloud-init clean --logs"
    ]
  }

}
