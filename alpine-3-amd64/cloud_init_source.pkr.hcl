source "file" "meta_data" {
  content = templatefile("${path.root}/templates/meta-data.pkrtpl", {
    template_name = var.template_name
  })
  target =  "${path.root}/http/meta-data"
}

source "file" "user_data" {
  content = templatefile("${path.root}/templates/user-data.pkrtpl", {
    ssh_username    = local.ssh_username
    ssh_password    = local.ssh_password
    ssh_public_keys = local.ssh_public_keys
  })
  target  = "${path.root}/http/user-data"
}
