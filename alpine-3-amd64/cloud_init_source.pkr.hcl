source "file" "meta_data" {
   content = <<EOF
local-hostname: ${ var.template_name }
EOF
  target =  "${path.root}/http/meta-data"
}

source "file" "user_data" {
  content = <<-EOF
#cloud-config
package_upgrade: true
disable_root: true
#timezone: "${ local.timezone }"
users:
  - name: ${ local.ssh_username }
    passwd: ${ bcrypt(local.ssh_password) }
    groups: [adm]
    lock-passwd: %{ if length(local.ssh_public_keys) > 0 }true%{ else }false%{ endif }
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/sh
%{ if length(local.ssh_public_keys) > 0 ~}
    ssh_authorized_keys:
%{ for key in local.ssh_public_keys ~}
      - ${key} 
%{ endfor ~}           
%{ endif ~}
runcmd:
  - [ rm, -f, /root/.ssh/authorized_keys ]
EOF
  target =  "${path.root}/http/user-data"
}



