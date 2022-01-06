source "file" "answers" {
  content = templatefile("${path.root}/templates/answers.pkrtpl", {
    keyboard_layout  = local.keyboard_layout
    keyboard_variant = local.keyboard_variant
    template_name    = var.template_name
    timezone         = local.timezone
    dns_servers      = local.dns_servers
  })
  target = "${path.root}/http/answers"
}

source "file" "setup" {
  content = templatefile("${path.root}/templates/alpine-setup.sh.pkrtpl", {
    ssh_public_key      = local.ssh_public_key
    use_public_key_auth = local.ssh_public_key != null ? true : false
  })
  target = "${path.root}/http/alpine-setup.sh"
}
