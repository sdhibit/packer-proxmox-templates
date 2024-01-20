source "file" "users" {
  content = templatefile("${path.root}/templates/users.nix.pkrtpl", {
    ssh_username           = var.ssh_username
    ssh_encrypted_password = bcrypt(var.ssh_password)
    ssh_public_keys        = [var.ssh_public_key]
  })
  target = "${path.root}/http/users.nix"
}

source "file" "configuration" {
  source = "${path.root}/files/configuration.nix"
  target = "${path.root}/http/configuration.nix"
}
