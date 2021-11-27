
# https://wiki.alpinelinux.org/wiki/Packer_installation
# No empty line breaks allowed...
source "file" "answers" {
  content = templatefile("${path.root}/templates/answers.pkrtpl", {
    keyboard_layout  = local.keyboard_layout
    keyboard_variant = local.keyboard_variant
    template_name    = var.template_name
    timezone         = local.timezone
  })
  target = "${path.root}/http/answers"
}
