locals {
  # "timestamp" template function replacement
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")

  use_iso_file = var.iso_file != null ? true : false

  http_server_host = var.http_server_host
  http_server_port = var.http_server_port
  http_url         = join("", ["http://", coalesce(var.http_server_host, "{{ .HTTPIP }}"), ":", coalesce(var.http_server_port, "{{ .HTTPPort }}")])

  disk_storage_pool       = var.disk_storage_pool
  disk_storage_pool_type  = var.disk_storage_pool_type
  cloud_init_storage_pool = coalesce(var.cloud_init_storage_pool, var.disk_storage_pool)

  language        = var.language
  keyboard_layout = var.keyboard_layout
  keyboard_keymap = var.keyboard_keymap
  timezone        = var.timezone

  ssh_username         = var.ssh_username
  ssh_password         = var.ssh_password
  ssh_private_key_file = var.ssh_private_key_file
  ssh_public_key       = var.ssh_public_key

  root_password = coalesce(var.root_password, uuidv4())
}
