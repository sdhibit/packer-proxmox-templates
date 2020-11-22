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

## Adding packer user with correct privileges 
pveum useradd packer@pve
pveum passwd packer@pve
pveum roleadd Packer -privs "VM.Config.Disk VM.Config.CPU VM.Config.Memory Datastore.AllocateSpace Sys.Modify VM.Config.Options VM.Allocate VM.Audit VM.Console VM.Config.CDROM VM.Config.Network VM.PowerMgmt VM.Config.HWType VM.Monitor"
pveum aclmod / -user packer@pve -role Packer