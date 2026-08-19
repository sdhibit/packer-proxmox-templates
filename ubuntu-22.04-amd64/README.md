# Ubuntu 22.04 AMD64

Ubuntu 22.04 LTS (jammy). Installs from the live-server ISO via subiquity autoinstall,
then converts the VM to a Proxmox template with a cloud-init drive attached.

Setup and prerequisites: see the [root README](../README.md).

## Build

```bash
packer init .
packer build -var-file=ubuntu-22.04.5.pkrvars.hcl -var-file=example.pkrvars.hcl .
```

## Versions

| Var-file | Notes |
| --- | --- |
| `ubuntu-22.04.5.pkrvars.hcl` | Current; mirrored by the directory defaults |
| `ubuntu-22.04.3.pkrvars.hcl` | Superseded |
| `ubuntu-22.04.2.pkrvars.hcl` | Superseded |

`releases.ubuntu.com` carries only the current point release, so the two superseded
pins already point at `old-releases.ubuntu.com`.

## Notes

- `user-data` is rendered from [templates/](templates/) with `templatefile`; `meta-data`
  is copied verbatim. Both are served over Packer's HTTP server.
- Defaults: 1024 MB RAM, 8 G disk, SSH user `packer`.
- Distinctive variables: `cloud_init_apt_packages`, `locale`, `keyboard_layout`.
