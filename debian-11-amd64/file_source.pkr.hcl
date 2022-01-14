source "file" "preseed" {
  content = templatefile("${path.root}/templates/preseed.cfg.pkrtpl", {
    repository_mirror_url  = var.repository_mirror_url
    language               = var.language
    country                = var.country
    locale                 = var.locale
    timezone               = var.timezone
    keyboard_keymap        = var.keyboard_keymap
    ssh_username           = var.ssh_username
    ssh_encrypted_password = bcrypt(var.ssh_password)
    ssh_public_key         = var.ssh_public_key
  })
  target = "${path.root}/http/preseed.cfg"
}
