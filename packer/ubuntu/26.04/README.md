# Ubuntu 26.04 AMD64

Ubuntu 26.04 LTS. Installs from the live-server ISO via subiquity autoinstall, then
converts the VM to a Proxmox template with a cloud-init drive attached.

Setup and prerequisites: see the [root README](../../../README.md).

## Build

```bash
packer init .
packer build -var-file=ubuntu-26.04.pkrvars.hcl -var-file=example.pkrvars.hcl .
```

## Versions

| Var-file | Notes |
| --- | --- |
| `ubuntu-26.04.pkrvars.hcl` | Current; mirrored by the directory defaults |

No point release in the filename yet - Ubuntu omits the `.0` on an initial release. When
26.04.1 ships the pinned URL 404s and the pin is bumped deliberately.

## Notes

- `user-data` is rendered from [templates/](templates/) with `templatefile`; `meta-data`
  is copied verbatim. Both are served over Packer's HTTP server.
- Defaults: 1024 MB RAM, 8 G disk, SSH user `packer`.
- Distinctive variables: `cloud_init_apt_packages`, `disable_ipv6`, `locale`, `keyboard_layout`.
