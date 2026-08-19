# Debian 11 AMD64

Debian 11 (bullseye). Installs from the netinst ISO via preseed, then converts the VM to a
Proxmox template with a cloud-init drive attached.

Setup and prerequisites: see the [root README](../README.md).

## Build

```bash
packer init .
packer build -var-file=debian-11.7.pkrvars.hcl -var-file=example.pkrvars.hcl .
```

## Versions

| Var-file | Notes |
| --- | --- |
| `debian-11.7.pkrvars.hcl` | Final 11.x release built here; mirrored by the directory defaults |

## Notes

- Kept for reproducing existing templates; new work should target
  [debian-13-amd64](../debian-13-amd64/).
- The ISO is pinned to `cdimage/archive/`, where superseded releases live.
- Defaults: 1024 MB RAM, 4 G disk, SSH user `packer`.
- Distinctive variables: `apt_packages`, `repository_mirror_url`, `language`, `country`,
  `locale`, `keyboard_keymap`.
