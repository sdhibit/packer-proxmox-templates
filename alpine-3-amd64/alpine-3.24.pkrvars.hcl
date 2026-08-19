template_name        = "alpine-3.24-virt-cloudinit"
template_description = "Base template for Alpine 3.24."

# Selects the setup-alpine prompt sequence. See locals.pkr.hcl.
alpine_minor_version = 24

# Uncomment if the ISO already exists in the 'iso_storage_pool' location
#iso_file     = "alpine-virt-3.24.1-x86_64.iso"
iso_url      = "https://dl-cdn.alpinelinux.org/alpine/v3.24/releases/x86_64/alpine-virt-3.24.1-x86_64.iso"
iso_checksum = "e73a6241bd5f3c5c2d4d38c02cc52c378c0415a7c888bd292066bf36e0f41a39"
