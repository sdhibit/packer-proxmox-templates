build {
  sources = [
    "source.proxmox-iso.talos"
  ]

  # Download talos nocloud image and write it to disk.
  provisioner "shell" {
    inline = [
      "curl -L ${local.talos_image} -o /tmp/talos.raw.xz",
      "xz -d -c /tmp/talos.raw.xz | dd of=/dev/sda && sync",
    ]
  }

}
