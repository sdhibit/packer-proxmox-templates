# packer-proxmox-templates

[Packer](https://www.packer.io) templates that build cloud-init-ready VM templates on
[Proxmox VE](https://www.proxmox.com/en/proxmox-virtual-environment/overview).

Each build boots an official netboot/live ISO, runs an unattended install (preseed,
subiquity autoinstall, or `setup-alpine` cli), installs cloud-init, cleans up the build
artifacts, and converts the VM into a Proxmox template with a cloud-init drive attached.
The result is a template ready to be cloned by Terraform/OpenTofu, Ansible, or the
Proxmox UI.

## Contents

- [Available templates](#available-templates)
- [Requirements](#requirements)
- [Quick start](#quick-start)
- [Configuration](#configuration)
- [Repository layout and versioning](#repository-layout-and-versioning)
- [Releases](#releases)
- [Proxmox setup](#proxmox-setup)
- [Development](#development)
- [Troubleshooting](#troubleshooting)
- [References](#references)

## Available templates

One directory per feature release, under `packer/`. Every directory is a self-contained
Packer configuration - `cd` into it and run `packer build` there.

| Directory | OS | Install method | Version var-files |
| --- | --- | --- | --- |
| [alpine/3/](packer/alpine/3/) | Alpine Linux 3 (virt) | `setup-alpine` + answer file | 3.18, 3.19, 3.20, 3.21, 3.24 |
| [debian/11/](packer/debian/11/) | Debian 11 (bullseye) | preseed | 11.7 |
| [debian/12/](packer/debian/12/) | Debian 12 (bookworm) | preseed | 12.8, 12.10, 12.15 |
| [debian/13/](packer/debian/13/) | Debian 13 (trixie) | preseed | 13.6 |
| [ubuntu/20.04/](packer/ubuntu/20.04/) | Ubuntu 20.04 LTS (focal) | subiquity autoinstall | 20.04.6 |
| [ubuntu/22.04/](packer/ubuntu/22.04/) | Ubuntu 22.04 LTS (jammy) | subiquity autoinstall | 22.04.2, 22.04.3, 22.04.5 |
| [ubuntu/24.04/](packer/ubuntu/24.04/) | Ubuntu 24.04 LTS (noble) | subiquity autoinstall | 24.04.4 |
| [ubuntu/26.04/](packer/ubuntu/26.04/) | Ubuntu 26.04 LTS | subiquity autoinstall | 26.04 |

Older directories are kept so a previously built template can be reproduced; new work
should target the newest feature release.

## Requirements

- A reachable **Proxmox VE** host, and an API user with the privileges listed under
  [Proxmox setup](#proxmox-setup).
- **Packer**, plus the `proxmox` plugin (`~> 1.2.4`, declared in each directory's
  `versions.pkr.hcl` and installed by `packer init`).
- **[mise](https://mise.jdx.dev)**, which installs the pinned toolchain.

```bash
mise install          # installs packer + pre-commit AND wires up the git hook
packer version        # v1.16.0
```

One command bootstraps a fresh clone. `pre-commit` comes from the aqua backend rather
than pipx - it ships a standalone binary, so this repo needs no Python toolchain - and a
`[hooks] postinstall` in [.mise.toml](.mise.toml) runs `pre-commit install` for you.
postinstall fires even when every tool is already present, so re-running is harmless.

The Packer version pin is deliberate and matches the version the consuming repo pins. A
floating `latest` on either side lets the two drift, turning a plugin or deprecation
change into a surprise at build time.

The plugin is pinned for the same reason, with `~> 1.2.4` - patches inside 1.2.x arrive
automatically, 1.3.0 needs a deliberate edit. Note the three-component form is what pins
the minor; `~> 1.2` would allow 1.3.0 through. Plugin 1.2.0 silently changed where boot
ISOs are written, which is exactly the class of surprise this prevents.

## Quick start

```bash
mise install                      # toolchain + git hook
cd packer/debian/13
packer init .                     # fetch the proxmox plugin
packer build \
  -var-file=debian-13.6.pkrvars.hcl \
  -var-file=example.pkrvars.hcl \
  .
```

Two var-files, by design: the first pins **what** is built (version, ISO, checksum) and
is committed here; the second supplies **where** it is built (host, credentials, storage
pools) and is not. `packer build` accepts repeated `-var-file` and the later one wins.

## Configuration

Site-specific values belong in a var-file that consumers keep in their own repo.
`example.pkrvars.hcl` and `*.auto.pkrvars.hcl` are gitignored, so a local copy is safe.

```hcl
# example.pkrvars.hcl
proxmox_host            = "proxmox.example.com"
proxmox_username        = "packer@pve!packer-token"
proxmox_token           = "00000000-0000-0000-0000-000000000000"
proxmox_node            = "pve1"

disk_storage_pool       = "local-lvm"
iso_storage_pool        = "local"
network_bridge          = "vmbr0"

template_vm_id          = 9000
ssh_public_key          = "ssh-ed25519 AAAA... you@example.com"
```

`proxmox_host` and `proxmox_username` are the only variables with no default - plus
`alpine_minor_version` in the Alpine directory. Authenticate with either `proxmox_token`
or `proxmox_password`. Every other variable -
CPU, memory, disk size and format, locale, timezone, extra packages, HTTP server
overrides - is documented inline in each directory's `variables.pkr.hcl`, which is the
authoritative reference.

## Repository layout and versioning

Template directories live under `packer/`, keeping the repository root for
tooling config and anything that is not a Packer build:

```
packer/<family>/<release>/

packer/
  alpine/3/
  debian/11/   12/   13/
  ubuntu/20.04/   22.04/   24.04/   26.04/
README.md            this file
.mise.toml           pinned toolchain
```

Within `packer/`, one directory per **feature release**, one `*.pkrvars.hcl` per
**point release**:

```
packer/debian/13/debian-13.6.pkrvars.hcl
packer/ubuntu/26.04/ubuntu-26.04.pkrvars.hcl
packer/alpine/3/alpine-3.24.pkrvars.hcl
```

Within a directory:

| File | Purpose |
| --- | --- |
| `build.pkr.hcl` | Provisioners: packages, cloud-init, cleanup |
| `proxmox_source.pkr.hcl` | The `proxmox-iso` source - hardware, disks, network, boot command |
| `variables.pkr.hcl` | Every input variable, with descriptions and validation |
| `locals.pkr.hcl` | Derived values, including Alpine's composed `boot_command` |
| `versions.pkr.hcl` | Required plugin versions |
| `file_source.pkr.hcl` / `cloud_init_source.pkr.hcl` | Renders `templates/` into `http/` for the installer to fetch |
| `templates/` | `.pkrtpl` answer files - preseed, user-data/meta-data, Alpine answers |
| `http/` | Where the rendered answer files land, served by Packer. Contents gitignored |
| `*.pkrvars.hcl` | One per point release: name, description, `iso_url`, `iso_checksum` |

A version var-file holds `template_name`, `template_description`, `iso_url` and
`iso_checksum`, plus `alpine_minor_version` for Alpine - a version pin is data, so it
belongs in a var-file, and the set of files is a reviewable list of what can be built.

Those same four defaults in `variables.pkr.hcl` mirror the directory's **newest**
var-file, so a build with no version var-file produces the current release rather than
whatever was current when the directory was created. They are the only defaults that go
stale, so they are bumped together with the var-file that supersedes them.

### Pin the full version, never a moving path

`current/`, `jammy/`, `noble/` and bare `26.04` directories are rewritten when a point
release ships. A URL under one of them first serves a **different image than its
checksum**, then 404s. Always pin a path and filename containing the full version, and
take the checksum from the same directory. Superseded releases move to
`cdimage.debian.org/cdimage/archive/` and `old-releases.ubuntu.com`.

When a pin 404s, that is working as intended: bump it deliberately.

### Alpine is the exception: `alpine_minor_version`

Alpine's directory is one per **major** (`alpine/3`), because 3.x shares one
builder - but its breaking changes land in *minor* releases. Debian and Ubuntu need no
equivalent, since their directories are already one per feature release.

A var-file can only change values. It cannot change the `boot_command`, and Alpine's
is a blind keystroke sequence answering `setup-alpine` prompts positionally: a release
that asks one more or one fewer question does not error, it hangs until
`ssh_timeout`. So `alpine_minor_version` is required in every Alpine var-file, and
[locals.pkr.hcl](packer/alpine/3/locals.pkr.hcl) composes `boot_command` from named
segments selected by it:

```hcl
setup_alpine_prompt_variant_by_minor = {
  # 25 = "25"        <- add an entry when a release changes the prompts
}
setup_alpine_variant = lookup(local.setup_alpine_prompt_variant_by_minor, var.alpine_minor_version, "18-24")
```

Everything not named there uses the `18-24` sequence. Adding a diverging release is one
map entry plus one segment - no new directory, and no risk to the releases already
working. The version is also passed into the answer templates, so a small difference
can be `%{ if alpine_minor_version >= 25 }` rather than a second file.

## Releases

Push a `v*` tag to cut a release. Nothing is compiled, so the assets are the source
archives GitHub attaches automatically.

```bash
git switch main && git pull
git tag -a v1.0.0 -m "v1.0.0"
git push origin v1.0.0
```

[.github/workflows/release.yml](.github/workflows/release.yml) runs CI first, refuses any
tag not reachable from `main`, then publishes with generated notes. A tag with a
pre-release suffix - `v1.1.0-rc.1` - publishes as a pre-release.

Tags version the repository, not individual templates. When a directory is removed at
end-of-life, the last release containing it stays downloadable, so a consumer pins that
tag:

```bash
git clone --branch v1.0.0 --depth 1 https://github.com/sdhibit/packer-proxmox-templates.git
```

Packer cannot fetch templates over the network - `packer build` and `-var-file` take local
paths, and `packer init` fetches plugins - so pinning is a source checkout, not something
Packer consumes.

## Proxmox setup

Create a dedicated API user and role with the minimum privileges Packer needs:

```bash
pveum useradd packer@pve
pveum passwd packer@pve
pveum roleadd Packer -privs "VM.Config.Disk VM.Config.CPU VM.Config.Memory \
  Datastore.AllocateSpace Datastore.AllocateTemplate Sys.Modify VM.Config.Options \
  VM.Allocate VM.Audit VM.Console VM.Config.CDROM VM.Config.Network VM.PowerMgmt \
  VM.Config.HWType SDN.Use"
pveum aclmod / -user packer@pve -role Packer
```

Two of these are easy to miss:

| Privilege | Needed for |
| --- | --- |
| `Datastore.AllocateTemplate` | Uploading the ISO to `iso_storage_pool`. Without it the build fails at upload; `Datastore.AllocateSpace` alone is not enough. |
| `SDN.Use` | Attaching the VM NIC to `network_bridge`. Required on PVE 8.2+, where bridge access moved behind an SDN permission check. |

Omit `Datastore.AllocateTemplate` only if every ISO is pre-staged and each var-file sets
`iso_file` instead of `iso_url`.

Prefer an API token over a password: create one for `packer@pve`, then set
`proxmox_username = "packer@pve!<token-id>"` and `proxmox_token = "<secret>"`.

## Development

[pre-commit](https://pre-commit.com) runs `check-yaml`, `end-of-file-fixer`,
`trailing-whitespace`, and the two [cisagov/pre-commit-packer](https://github.com/cisagov/pre-commit-packer)
hooks, `packer_fmt` and `packer_validate`. Validation runs `packer validate -syntax-only`
per template directory; syntax-only skips variable evaluation, which is what lets it run
with no Proxmox host, no credentials, and no site var-file.

```bash
pre-commit run --all-files
```

`--all-files` only covers files **git already tracks**, so a brand new template
directory is silently skipped until it is committed. Check one explicitly:

```bash
pre-commit run packer_validate --files <dir>/build.pkr.hcl
```

Both hooks are configured with non-empty `args` deliberately - the v0.3.1 scripts expand
`"${ARGS[@]}"` under `set -o nounset`, which aborts on the bash 3.2 that macOS ships.
`packer_validate` also has its `files` pattern widened to match `*.pkrvars.hcl`, so that
adding a point release - which touches no `.pkr.hcl` file at all - still triggers a check.
See [.pre-commit-config.yaml](.pre-commit-config.yaml).

### Continuous integration

[.github/workflows/ci.yml](.github/workflows/ci.yml) runs on pull requests, pushes to
`main`, and as the first half of a release: `pre-commit`, `packer fmt -check`, then a
matrix of one job per template directory running `packer init`, a full `packer validate`,
and one `packer validate -var-file=` per point release.

CI validates fully rather than `-syntax-only`, so `templatefile()` is expanded and a
source passing variables its answer template never reads fails. That needs the four
variables with no default, supplied as dummy `PKR_VAR_*` values pointing at
`proxmox.invalid`, which cannot resolve.

Reproducing a failure locally: validate from *inside* the directory, since
`templatefile("templates/...")` resolves against the working directory.

```bash
export PKR_VAR_proxmox_host=proxmox.invalid
export PKR_VAR_proxmox_username=validate@pve
export PKR_VAR_proxmox_password=validate
export PKR_VAR_alpine_minor_version=24

for dir in packer/*/*/; do
  (cd "$dir" && packer init . && packer validate .) || echo "FAILED: $dir"
done
```

The matrix comes from `git ls-files`, so a directory is covered once committed. Actions
are pinned to commit SHAs; bumping one means replacing the SHA and its version comment.

### Adding a point release

1. Copy the newest `*.pkrvars.hcl` in the directory to the new version's filename.
2. Update `template_name`, `template_description`, `iso_url`, and `iso_checksum` - with
   the checksum taken from the checksum file in the *same* directory as the ISO.
3. Copy those same four values into the matching defaults in `variables.pkr.hcl`, so the
   directory defaults keep pointing at the newest release.
4. For Alpine, set `alpine_minor_version`; add a prompt-variant segment only if
   `setup-alpine`'s questions changed.
5. Run the validate hook against the directory, then build once against a real host.

### Adding a feature release

Copy the closest existing directory, update the answer templates and any
release-specific defaults, then add one version var-file as above.

## Troubleshooting

### Build hangs, then fails at `ssh_timeout`

The unattended installer never completed. For Alpine this usually means the
`setup-alpine` prompt sequence drifted - see
[`alpine_minor_version`](#alpine-is-the-exception-alpine_minor_version). Watch the VM
console in the Proxmox UI to see which prompt it is stuck on.

### Running on a NAT'ed network (WSL2, ChromeOS Linux)

WSL2 runs a virtual network, so Packer's HTTP server - which serves the preseed or
autoinstall files to the booting VM - is not reachable from the VM by default. Apply
firewall and port-forwarding rules on the Windows host, then pin Packer to the
forwarded port and the reachable host IP with `http_server_host`, `http_server_port`,
`http_bind_address`, and `http_interface`.

Reference links for WSL2 / ChromeOS port forwarding:

- <https://winaero.com/open-port-windows-firewall-windows-10/>
- <https://docs.microsoft.com/en-us/windows/wsl/compare-versions#accessing-a-wsl-2-distribution-from-your-local-area-network-lan>
- <https://serverfault.com/questions/883266/powershell-how-open-a-windows-firewall-port>
- <https://dev.to/vishnumohanrk/wsl-port-forwarding-2e22>
- <https://github.com/microsoft/WSL/issues/4150#issuecomment-504209723>
- <https://github.com/shayne/go-wsl2-host>
- <https://github.com/shayne/wsl2-hacks>
- <https://chromeos.dev/en/web-environment/port-forwarding>

### Where the installer ISO is downloaded

Builds download the ISO to `<template-dir>/downloaded_iso_path/`, named after its
checksum rather than the release. That directory is gitignored and Packer creates it, so
nothing is committed for it.

`boot_iso.iso_target_path` is set to that same path, which looks redundant and is - the
plugin ignores the setting entirely. `common/builder.go` passes the *state key* rather
than the configured path to the download step, so the boot ISO always lands in a relative
`downloaded_iso_path` regardless of configuration, and `PACKER_CACHE_DIR` cannot override
it either. The setting is pinned to the real location so that a fixed plugin keeps
behaving exactly as it does today instead of silently relocating the ISO.

This is a regression: `iso_target_path` worked until the boot ISO was folded into the
shared ISO handling in plugin v1.2.0. **When it is fixed upstream, point
`iso_target_path` wherever you actually want the ISOs** - and if that is a committed
directory, it needs a `.gitignore` of its own like `http/` has.

### Alpine: cloud-init drive not loading

cloud-init mounts the Proxmox cloud-init CDROM with `-t auto`, and the Alpine virt image
does not recognize `iso9660` by default, so the drive never mounts. The build handles
this by loading the `isofs` module at boot
([build.pkr.hcl](packer/alpine/3/build.pkr.hcl)):

```hcl
"echo 'isofs' > /etc/modules-load.d/isofs.conf",
```

To confirm on a running guest, check that `iso9660` is listed:

```bash
cat /proc/filesystems
```

## References

Background reading collected while building these templates. Links are labelled so a
dead one can be replaced without having to open it first; checked August 2026.

### Packer and Proxmox

- [Proxmox builder documentation gaps](https://github.com/hashicorp/packer-plugin-proxmox/issues/184) - packer-plugin-proxmox#184 (was packer#8463 before the builder was split into its own plugin repo)
- [Packer fails to build for Ubuntu 20.04](https://github.com/hashicorp/packer/issues/9115#issuecomment-688991546) - the comment, not the issue, is the useful part
- [dustinrue/proxmox-packer](https://github.com/dustinrue/proxmox-packer) - a comparable repo, actively maintained and now HCL
- [cisagov/skeleton-packer#6](https://github.com/cisagov/skeleton-packer/issues/6) - leftover `admin` user in a built image
- [Provisioning Proxmox VMs with Ansible](https://medium.com/@victor.oliveira.comp/provision-proxmox-vms-with-ansible-quick-and-easy-107d781fd749) - consuming the templates once built

### cloud-init and image cleanup

- [Removing the install user with Packer](https://serverfault.com/questions/842315/removing-install-user-with-packer)
- [Removing the packer user at provisioning](https://github.com/Azure/aks-engine/issues/899) - aks-engine is retired; the cleanup discussion still applies
- [Ubuntu 20.04 cloud-init gotchas](https://everythingshouldbevirtual.com/Ubuntu-20.04-cloud-init-gotchas/)
- [`UsePAM` no longer supported](https://serverfault.com/questions/991009/usepam-not-supported-anymore) - background for the sshd edits in the cleanup provisioners
- [Locked accounts refuse SSH login](https://github.com/camptocamp/puppet-accounts/issues/35) - why Alpine locks rather than deletes root
- [Ubuntu DashAsBinSh](https://wiki.ubuntu.com/DashAsBinSh) - `/bin/sh` is dash, which is why provisioners avoid bashisms

### Alpine

- [chriswayg/packer-proxmox-templates](https://github.com/chriswayg/packer-proxmox-templates/blob/master/alpine-3-amd64-proxmox/alpine-3-amd64-proxmox.json) - the original this repo's Alpine build descends from (pre-HCL, unmaintained since 2021)
- [bobfraser1/packer-alpine](https://github.com/bobfraser1/packer-alpine/blob/main/alpine.json)
- [stvnjacobs/packer-alpine](https://github.com/stvnjacobs/packer-alpine/blob/master/alpine.json) - unmaintained since 2019
- [`setup-alpine` answer file examples](https://gist.github.com/s3rj1k/55b10cd20f31542046018fcce32f103e)
- [Alpine cloud-init on Proxmox](https://gist.github.com/thde/5312a42665c5c901aef4)
- [Alpine Packer boot command](https://gist.github.com/imduffy15/2d6f3cd46efa2ff68286)
