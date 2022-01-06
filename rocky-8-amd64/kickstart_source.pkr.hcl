source "file" "kickstart" {
  content = templatefile("${path.root}/templates/ks.cfg.pkrtpl", {
    root_password   = bcrypt(local.root_password, 6)
    language        = local.language
    timezone        = local.timezone
    keyboard_layout = local.keyboard_layout
    keyboard_keymap = local.keyboard_keymap
    ssh_username    = local.ssh_username
    ssh_password    = bcrypt(local.ssh_password, 6)
    ssh_public_key  = local.ssh_public_key
  })
  target = "${path.root}/http/ks.cfg"
}
