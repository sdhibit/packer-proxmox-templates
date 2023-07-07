locals {
  talos_image = "https://github.com/talos-systems/talos/releases/download/v${var.talos_version}/nocloud-amd64.raw.xz"

  use_iso_file = var.iso_file != null ? true : false

  template_name        = "talos-${var.talos_version}-cloudinit"
  template_description = "Talos NoCloud Image - v${var.talos_version}"

  cloud_init_storage_pool = coalesce(var.cloud_init_storage_pool, var.disk_storage_pool)
}
