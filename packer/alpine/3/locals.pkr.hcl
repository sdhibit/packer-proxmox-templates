locals {
  # "timestamp" template function replacement
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")

  use_iso_file = var.iso_file != null ? true : false

  http_url = join("", ["http://", coalesce(var.http_server_host, "{{ .HTTPIP }}"), ":", coalesce(var.http_server_port, "{{ .HTTPPort }}")])

  cloud_init_storage_pool = coalesce(var.cloud_init_storage_pool, var.disk_storage_pool)

  root_password = coalesce(var.root_password, uuidv4())

  # setup-alpine installs to a device name, so the disk type decides it: a virtio disk
  # appears as /dev/vda, ide, sata and scsi all appear as /dev/sda.
  root_device = var.disk_type == "virtio" ? "/dev/vda" : "/dev/sda"

  # setup-alpine is answered blind and positionally. A release that asks a different
  # number of questions hangs until ssh_timeout instead of failing, so the sequence is
  # kept in named segments per minor version rather than one literal list.
  boot_prelude = [
    "root<enter><wait>",
    "ifconfig eth0 up && udhcpc -i eth0<enter><wait5>", # Start networking with DHCP
    "wget ${local.http_url}/answers<enter><wait>",
    "sed -i 's/\\r$//g' $PWD/answers<enter><wait>", # Strip CR if generated on Windows
  ]

  # Root password twice, decline the extra user, confirm erasing the disk.
  setup_alpine_prompts = {
    "18-24" = [
      "USERANSERFILE=1 setup-alpine -f $PWD/answers<enter><wait10>",
      "${local.root_password}<enter><wait>",
      "${local.root_password}<enter><wait>",
      "no<enter><wait10>",
      "y<enter><wait20>",
    ]
  }

  # Add an entry when a release changes setup-alpine's questions. Everything else
  # falls back to "18-24".
  setup_alpine_prompt_variant_by_minor = {
    # 25 = "25"
  }

  setup_alpine_variant = lookup(local.setup_alpine_prompt_variant_by_minor, var.alpine_minor_version, "18-24")

  # Reboot into the installed system, then fetch and run the post-install script.
  boot_postlude = [
    "reboot<enter>",
    "<wait30>",
    "root<enter><wait>",
    "${local.root_password}<enter><wait>",
    "wget ${local.http_url}/alpine-setup.sh<enter><wait>",
    "chmod +x $PWD/alpine-setup.sh<enter><wait>",
    "sed -i 's/\\r$//g' $PWD/alpine-setup.sh<enter><wait>",
    "$PWD/alpine-setup.sh<enter><wait>",
  ]

  boot_command = concat(
    local.boot_prelude,
    local.setup_alpine_prompts[local.setup_alpine_variant],
    local.boot_postlude,
  )
}
