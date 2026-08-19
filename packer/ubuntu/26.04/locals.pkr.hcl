locals {
  # Empty unless disable_ipv6 is set, so the cmdline keeps its original spacing.
  ipv6_cmdline = var.disable_ipv6 ? " ipv6.disable=1" : ""

  # "timestamp" template function replacement
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")

  use_iso_file = var.iso_file != null ? true : false

  http_url = join("", ["http://", coalesce(var.http_server_host, "{{ .HTTPIP }}"), ":", coalesce(var.http_server_port, "{{ .HTTPPort }}")])

  cloud_init_storage_pool = coalesce(var.cloud_init_storage_pool, var.disk_storage_pool)
}
