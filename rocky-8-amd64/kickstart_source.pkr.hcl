source "file" "kickstart" {
  content = templatefile("${path.root}/templates/ks.cfg.pkrtpl", {
    root_password   = bcrypt(local.root_password, 6)
    language        = var.language
    timezone        = var.timezone
    keyboard_layout = var.keyboard_layout
    keyboard_keymap = var.keyboard_keymap
    ssh_username    = var.ssh_username
    ssh_password    = bcrypt(var.ssh_password, 6)
    ssh_public_key  = var.ssh_public_key
  })
  target = "${path.root}/http/ks.cfg"
}
