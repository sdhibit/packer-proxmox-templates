
# https://wiki.alpinelinux.org/wiki/Packer_installation
# No empty line breaks allowed...
source "file" "answers" {
  content = <<-EOF
KEYMAPOPTS="${ local.keyboard_layout } ${ local.keyboard_variant }"
HOSTNAMEOPTS="-n ${ var.template_name }"
INTERFACESOPTS="auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
"
DNSOPTS="-n 8.8.8.8"
TIMEZONEOPTS="-z ${ var.timezone }"
PROXYOPTS="none"
APKREPOSOPTS="-1"
SSHDOPTS="-c openssh"
NTPOPTS="-c chrony"
DISKOPTS="-m sys /dev/sda"
EOF
  target =  "${path.root}/http/answers"
}