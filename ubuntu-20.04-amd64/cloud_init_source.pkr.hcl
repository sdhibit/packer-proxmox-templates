source "file" "meta_data" {
  source =  "${path.root}/templates/meta-data.tpl"
  target =  "${path.root}/http/meta-data"
}

source "file" "user_data" {
  content = <<-EOF
#cloud-config
autoinstall:
  version: 1
  locale: ${local.locale}
  keyboard:
    layout: ${local.layout}
    variant: ${local.variant}  
  network:
    network:
      version: 2
      ethernets:
        mainif:
          match:
            name: e*
          critical: true
          dhcp4: true
          dhcp-identifier: mac
  ssh:
    install-server: true
    allow-pw: %{ if length(local.ssh_public_keys) > 0 }false%{ else }true%{ endif }
  packages:
    - qemu-guest-agent
%{ for package in local.cloud_init_apt_packages ~}
    - ${package} 
%{ endfor ~} 
  storage:
    layout:
      name: direct
    swap:
      size: 0
  late-commands:
    - sed -ie 's/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="net.ifnames=0 ipv6.disable=1 biosdevname=0"/' /target/etc/default/grub
    - curtin in-target --target /target update-grub2
  user-data:
    package_upgrade: true
    users:
      - name: ${ local.ssh_username }
        passwd: ${ bcrypt(local.ssh_password) }
        groups: [adm, cdrom, dip, plugdev, lxd, sudo]
        lock-passwd: %{ if length(local.ssh_public_keys) > 0 }true%{ else }false%{ endif }
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
%{ if length(local.ssh_public_keys) > 0 ~}
        ssh_authorized_keys:
%{ for key in local.ssh_public_keys ~}
          - ${key} 
%{ endfor ~}           
%{ endif ~}
EOF
  target =  "${path.root}/http/user-data"
}



