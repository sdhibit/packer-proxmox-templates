# Ubuntu 20.04 AMD64

Ubuntu 20.04 LTS (focal). Installs from the live-server ISO via subiquity autoinstall,
then converts the VM to a Proxmox template with a cloud-init drive attached.

Setup and prerequisites: see the [root README](../../../README.md).

## Build

```bash
packer init .
packer build -var-file=ubuntu-20.04.6.pkrvars.hcl -var-file=example.pkrvars.hcl .
```

## Versions

| Var-file | Notes |
| --- | --- |
| `ubuntu-20.04.6.pkrvars.hcl` | Final 20.04 release built here; mirrored by the directory defaults |

## Notes

- Kept for reproducing existing templates; new work should target
  [ubuntu/26.04](../26.04/).
- The ISO is still pinned to `releases.ubuntu.com`. When 20.04 rotates off, the pin
  will 404 and moves to `old-releases.ubuntu.com`.
- `user-data` is rendered from [templates/](templates/) with `templatefile`; `meta-data`
  is copied verbatim. Both are served over Packer's HTTP server.
- Defaults: 1024 MB RAM, 8 G disk, SSH user `packer`.
- Distinctive variables: `cloud_init_apt_packages`, `disable_ipv6`, `locale`, `keyboard_layout`, `keyboard_variant`.
