locals {
  # "timestamp" template function replacement
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")

  use_iso_file = var.iso_file != null ? true : false

  http_server_host  = var.http_server_host
  http_server_port  = var.http_server_port
  http_url          = join("", ["http://", coalesce(var.http_server_host, "{{ .HTTPIP }}"), ":", coalesce(var.http_server_port, "{{ .HTTPPort }}")])

  disk_storage_pool       = var.disk_storage_pool
  disk_storage_pool_type  = var.disk_storage_pool_type
  cloud_init_storage_pool = var.cloud_init_storage_pool != null ? var.cloud_init_storage_pool : var.disk_storage_pool

  locale            = var.locale
  keyboard_layout   = var.keyboard_layout
  keyboard_variant  = var.keyboard_variant
  timezone          = var.timezone

  ssh_username              = var.ssh_username
  ssh_password              = var.ssh_password
  ssh_private_key_file      = var.ssh_private_key_file
  ssh_public_key            = var.ssh_public_key

  ssh_public_keys = compact([
    local.ssh_public_key
  ])

  cloud_init_apt_packages = var.cloud_init_apt_packages != null ? var.cloud_init_apt_packages : []

}
