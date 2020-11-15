#cloud-config
autoinstall:
  version: 1
  locale: ${local.locale}
  keyboard:
    layout: ${local.layout}
    variant: ${local.variant}
  ssh:
    install-server: true
%{ if length(local.ssh_public_keys) > 0 ~}
    authorized-keys:
%{ for key in local.ssh_public_keys ~}
      - ${key} 
%{ endfor ~}
%{ endif ~}
    allow-pw: %{ if length(local.ssh_public_keys) > 0 }false%{ else }true%{ endif }
  packages:
    - qemu-guest-agent
  storage:
    layout:
      name: direct
    swap:
      size: 0
  user-data:
    package_upgrade: false
    users:
      - name: ${ local.ssh_username }
        passwd: ${ bcrypt(local.ssh_password) }
        groups: [adm, cdrom, dip, plugdev, lxd, sudo]
        lock-passwd: false
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
%{ if length(local.ssh_public_keys) > 0 ~}
        ssh_authorized_keys:
%{ for key in local.ssh_public_keys ~}
          - ${key} 
%{ endfor ~}           
%{ endif ~}