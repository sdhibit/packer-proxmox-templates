# Ubuntu 24.04 AMD64

Ubuntu 24.04 LTS (noble). Installs from the live-server ISO via subiquity autoinstall,
then converts the VM to a Proxmox template with a cloud-init drive attached.

Setup and prerequisites: see the [root README](../README.md).

## Build

```bash
packer init .
packer build -var-file=ubuntu-24.04.4.pkrvars.hcl -var-file=example.pkrvars.hcl .
```

## Versions

| Var-file | Notes |
| --- | --- |
| `ubuntu-24.04.4.pkrvars.hcl` | Current; mirrored by the directory defaults |

Ubuntu rewrites `noble/` and bare `24.04/` paths on every point release, so the pin uses
a version-explicit filename. When it 404s, bump it deliberately.

## Notes

- `user-data` is rendered from [templates/](templates/) with `templatefile`; `meta-data`
  is copied verbatim. Both are served over Packer's HTTP server.
- Defaults: 1024 MB RAM, 8 G disk, SSH user `packer`.
- Distinctive variables: `cloud_init_apt_packages`, `locale`, `keyboard_layout`.
