source "file" "answers" {
  content = templatefile("${path.root}/templates/answers.pkrtpl", {
    keyboard_layout  = var.keyboard_layout
    keyboard_variant = var.keyboard_variant
    timezone         = var.timezone
    dns_servers      = var.dns_servers
  })
  target = "${path.root}/http/answers"
}

source "file" "setup" {
  content = templatefile("${path.root}/templates/alpine-setup.sh.pkrtpl", {
    ssh_public_key      = var.ssh_public_key
    use_public_key_auth = var.ssh_public_key != null ? true : false
  })
  target = "${path.root}/http/alpine-setup.sh"
}
