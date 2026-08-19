locals {
  # "timestamp" template function replacement
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")

  # Use local ISO file if provided
  use_iso_file = var.iso_file != null ? true : false

  # Useful when behind NAT or port forwarding scenarios
  http_url = join("", ["http://", coalesce(var.http_server_host, "{{ .HTTPIP }}"), ":", coalesce(var.http_server_port, "{{ .HTTPPort }}")])

  # Set the cloud init drive storage to the local disk storage if not provided
  cloud_init_storage_pool = coalesce(var.cloud_init_storage_pool, var.disk_storage_pool)
}
