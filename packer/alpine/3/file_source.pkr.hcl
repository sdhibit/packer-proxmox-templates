source "file" "answers" {
  content = templatefile("${path.root}/templates/answers.pkrtpl", {
    keyboard_layout  = var.keyboard_layout
    keyboard_variant = var.keyboard_variant
    timezone         = var.timezone
    dns_servers      = var.dns_servers

    # Lets a release-specific answer use %{ if alpine_minor_version >= 25 } instead of
    # a second file.
    alpine_minor_version = var.alpine_minor_version
  })
  target = "${path.root}/http/answers"
}

source "file" "setup" {
  content = templatefile("${path.root}/templates/alpine-setup.sh.pkrtpl", {
    ssh_public_key      = var.ssh_public_key != null ? var.ssh_public_key : ""
    use_public_key_auth = var.ssh_public_key != null ? true : false
    apk_packages        = var.apk_packages
    use_openssh_pam     = var.use_openssh_pam

    # Same reason as in the answers file above.
    alpine_minor_version = var.alpine_minor_version
  })
  target = "${path.root}/http/alpine-setup.sh"
}
