build {
  name = "Talos"

  sources = [
    "source.file.schematic",
    "source.proxmox-iso.talos",
  ]

  # Packages
  provisioner "shell" {
    execute_command = "/bin/sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "apk update",
      "apk add --no-cache jq xz",
      "id=$(curl -s -X POST --data-binary @/tmp/schematic.yaml ${local.talos_factory_url}/schematics | jq -r '.id')",
      "curl -L ${local.talos_factory_url}/image/$id/${var.talos_version}/nocloud-amd64.raw.xz -o /tmp/talos.raw.xz",
      "xz -d -c /tmp/talos.raw.xz | dd of=${local.disk_device} && sync",
    ]
  }

}
