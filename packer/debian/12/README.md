# Debian 12 AMD64

Debian 12 (bookworm). Installs from the netinst ISO via preseed, then converts the VM to a
Proxmox template with a cloud-init drive attached.

Setup and prerequisites: see the [root README](../../../README.md).

## Build

```bash
packer init .
packer build -var-file=debian-12.15.pkrvars.hcl -var-file=example.pkrvars.hcl .
```

## Versions

| Var-file | Notes |
| --- | --- |
| `debian-12.15.pkrvars.hcl` | Current; mirrored by the directory defaults |
| `debian-12.10.pkrvars.hcl` | Superseded |
| `debian-12.8.pkrvars.hcl` | Superseded |

All three pins point at `cdimage/archive/`, where superseded Debian releases live.

## Notes

- Defaults: 1024 MB RAM, 4 G disk, SSH user `packer`.
- Distinctive variables: `apt_packages`, `repository_mirror_url`, `language`, `country`,
  `locale`, `keyboard_keymap`.
