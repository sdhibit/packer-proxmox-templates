# packer-proxmox-templates
Proxmox images built with Packer

Requires Proxmox >= 1.6.6 which fixes proxmox boot order change in pve-6.2-15
https://git.proxmox.com/?p=qemu-server.git;a=commit;h=2141a802b843475be82e04d8c351d6f7cd1a339a
https://github.com/hashicorp/packer/issues/10252

## Links
- https://serverfault.com/questions/842315/removing-install-user-with-packer
- https://github.com/Azure/aks-engine/issues/899
- https://github.com/cisagov/skeleton-packer/issues/6
- https://www.endpoint.com/blog/2014/03/14/provisioning-development-environment_14
- https://github.com/dustinrue/proxmox-packer/blob/master/centos8/packer.json
- https://github.com/hashicorp/packer/issues/8463
- https://everythingshouldbevirtual.com/Ubuntu-20.04-cloud-init-gotchas/
- https://wiki.ubuntu.com/DashAsBinSh
- https://github.com/hashicorp/packer/issues/9115#issuecomment-688991546
- https://gist.github.com/s3rj1k/55b10cd20f31542046018fcce32f103e
- https://gist.github.com/thde/5312a42665c5c901aef4
- https://github.com/chriswayg/packer-proxmox-templates/blob/master/alpine-3-amd64-proxmox/alpine-3-amd64-proxmox.json
- https://github.com/bobfraser1/packer-alpine/blob/main/alpine.json
- https://github.com/stvnjacobs/packer-alpine/blob/master/alpine.json
- https://medium.com/@victor.oliveira.comp/provision-proxmox-vms-with-ansible-quick-and-easy-107d781fd749
- https://gist.github.com/imduffy15/2d6f3cd46efa2ff68286
- https://serverfault.com/questions/991009/usepam-not-supported-anymore
- https://github.com/camptocamp/puppet-accounts/issues/35

## Adding packer user with correct privileges
pveum useradd packer@pve
pveum passwd packer@pve
pveum roleadd Packer -privs "VM.Config.Disk VM.Config.CPU VM.Config.Memory Datastore.AllocateSpace Sys.Modify VM.Config.Options VM.Allocate VM.Audit VM.Console VM.Config.CDROM VM.Config.Network VM.PowerMgmt VM.Config.HWType VM.Monitor"
pveum aclmod / -user packer@pve -role Packer

#apk add dos2unix --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community/ --allow-untrusted

## Running on NAT'ed network (ChromeOS Linux, WSL2)

WSL2 runs a virtual network . If running packer on WSL2, some firewall and port-forwarding settings must be applied on Windows in order for packer's HTTP server to be accessible to the virtual machine. A few packer variables should also be set in order to use the known, port-forwarded port and override the packer HTTP IP with the Windows host IP that's accessible to the VM being built.

- https://winaero.com/open-port-windows-firewall-windows-10/
- https://docs.microsoft.com/en-us/windows/wsl/compare-versions#accessing-a-wsl-2-distribution-from-your-local-area-network-lan
- https://serverfault.com/questions/883266/powershell-how-open-a-windows-firewall-port
- https://dev.to/vishnumohanrk/wsl-port-forwarding-2e22
- https://github.com/microsoft/WSL/issues/4150#issuecomment-504209723
- https://github.com/shayne/go-wsl2-host
- https://github.com/shayne/wsl2-hacks
- https://chromeos.dev/en/web-environment/port-forwarding

# Alpine cloud-init drive not loading

cloud-init tries to mount the Proxmox cloud-init CDROM with the -t auto flag. iso9660 is not recognized by default in the virt alpine image. The 'isofs' module needs to be loaded in order for cloud-init to mount the proxmox cloud-init drive

```bash
# Check if iso9660 is in /proc/filesystems
cat /proc/filesystems


```
