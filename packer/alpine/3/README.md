# Alpine 3 AMD64

Alpine Linux 3 (`virt` image). Boots the virt ISO, drives `setup-alpine` through a
scripted keystroke sequence and answer file, installs cloud-init, then converts the VM to
a Proxmox template with a cloud-init drive attached.

Setup and prerequisites: see the [root README](../../../README.md).

## Build

```bash
packer init .
packer build -var-file=alpine-3.24.pkrvars.hcl -var-file=example.pkrvars.hcl .
```

## Versions

| Var-file | `alpine_minor_version` |
| --- | --- |
| `alpine-3.24.pkrvars.hcl` | 24 |

The newest var-file (3.24) is mirrored by the directory defaults. Releases older than
3.24 are end-of-life and were removed; `alpine_minor_version` rejects them.

This is the only directory covering a whole major series, so every var-file must set
`alpine_minor_version`. `setup-alpine`'s prompts change between minor releases and the
`boot_command` answers them blind and positionally - a release that asks one more or one
fewer question does not error, it hangs until `ssh_timeout` (45m). The variable selects a
prompt sequence in [locals.pkr.hcl](locals.pkr.hcl); anything not listed there uses the
`24` sequence. See the [root README](../../../README.md#alpine-is-the-exception-alpine_minor_version).

## Notes

- Defaults are deliberately small: 512 MB RAM, 1 G disk.
- Packer connects as `root`; the cleanup provisioner then locks the root password and
  sets `PermitRootLogin no`, so the finished template is reachable only via cloud-init.
- Cleanup removes `/var/lib/seedrng`, Alpine's RNG seed directory - clones would
  otherwise share an entropy state. Alpine uses seedrng, not systemd's random-seed.
- `isofs` is loaded at boot via `/etc/modules-load.d/`. Without it the Proxmox cloud-init
  CDROM never mounts - see [build.pkr.hcl](build.pkr.hcl).
- Distinctive variables: `apk_packages`, `root_password`, `use_openssh_pam`,
  `dns_servers`, `keyboard_layout`, `keyboard_variant`.
