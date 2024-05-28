source "file" "meta_data" {
  source = "${path.root}/templates/meta-data.pkrtpl"
  target = "${path.root}/http/meta-data"
}

source "file" "user_data" {
  content = templatefile("${path.root}/templates/user-data.pkrtpl", {
    locale           = var.locale
    timezone         = var.timezone
    keyboard_layout  = var.keyboard_layout
    keyboard_variant = var.keyboard_variant
    ssh_username     = var.ssh_username
    ssh_password     = bcrypt(var.ssh_password)
    ssh_public_keys  = compact([var.ssh_public_key])
    apt_packages     = var.apt_packages
  })
  target = "${path.root}/http/user-data"
}
