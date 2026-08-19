template_name        = "ubuntu-26.04-cloudinit"
template_description = "Base template for Ubuntu 26.04 LTS."

# Uncomment if the ISO already exists in the 'iso_storage_pool' location
#iso_file      = "ubuntu-26.04-live-server-amd64.iso"
# No .0 on an initial Ubuntu release; 26.04.1 will need a new pin.
iso_url      = "https://releases.ubuntu.com/26.04/ubuntu-26.04-live-server-amd64.iso"
iso_checksum = "dec49008a71f6098d0bcfc822021f4d042d5f2db279e4d75bdd981304f1ca5d9"
