# Debian 13 AMD64

Debian 13 (trixie). Installs from the netinst ISO via preseed, then converts the VM to a
Proxmox template with a cloud-init drive attached.

Setup and prerequisites: see the [root README](../README.md).

## Build

```bash
packer init .
packer build -var-file=debian-13.6.pkrvars.hcl -var-file=example.pkrvars.hcl .
```

## Versions

| Var-file | Notes |
| --- | --- |
| `debian-13.6.pkrvars.hcl` | Current; mirrored by the directory defaults |

## Notes

- The preseed is unchanged from Debian 12 - trixie's netinst still uses
  debian-installer, so the directives carry over.
- Defaults: 1024 MB RAM, 4 G disk, SSH user `packer`.
- Distinctive variables: `apt_packages`, `repository_mirror_url`, `language`, `country`,
  `locale`, `keyboard_keymap`.
