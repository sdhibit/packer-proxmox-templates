locals { 
  # "timestamp" template function replacement
  timestamp = regex_replace(timestamp(), "[- TZ:]", "") 

  use_iso_file = var.iso_file != null ? true : false

  //en_US
  locale = "en_US"
  layout = "en"
  variant = "us"

  ssh_username              = var.ssh_username
  ssh_password              = var.ssh_password
  ssh_private_key_file      = var.ssh_private_key_file
  ssh_public_key            = var.ssh_public_key
  
  ssh_public_keys = compact([
    local.ssh_public_key
  ])

}