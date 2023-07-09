source "file" "autoinst" {
  content = templatefile("${path.root}/templates/autoinst.xml.pkrtpl", {
    language               = var.language
    is_hwclock_utc         = true
    timezone               = var.timezone
    keyboard_keymap        = var.keyboard_keymap
    ssh_username           = var.ssh_username
    ssh_encrypted_password = bcrypt(var.ssh_password)
    ssh_public_key         = var.ssh_public_key
  })
  target = "${path.root}/http/autoinst.xml"
}
