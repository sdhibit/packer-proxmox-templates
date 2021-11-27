source "file" "meta_data" {
  source = "${path.root}/templates/meta-data.pkrtpl"
  target = "${path.root}/http/meta-data"
}

source "file" "user_data" {
  content = templatefile("${path.root}/templates/user-data.pkrtpl", {
    locale                  = local.locale
    timezone                = local.timezone
    keyboard_layout         = local.keyboard_layout
    keyboard_variant        = local.keyboard_variant
    ssh_username            = local.ssh_username
    ssh_password            = local.ssh_password
    ssh_public_keys         = local.ssh_public_keys
    cloud_init_apt_packages = local.cloud_init_apt_packages
  })
  target = "${path.root}/http/user-data"
}
