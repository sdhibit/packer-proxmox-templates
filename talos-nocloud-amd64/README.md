http://tinycorelinux.net/15.x/x86/release/Core-15.0.iso
9f031b429a5c871523a4b377612812a7  Core-15.0.iso

https://iotbytes.wordpress.com/configure-ssh-server-on-microcore-tiny-linux/
https://itadminguide.com/install-ssh-server-on-tiny-core-linux/
https://github.com/lveyde/tcl-qemu-ga/blob/main/TinyCoreLinuxWithQemuGuestAgent.pkr.hcl
https://ochoaprojects.github.io/posts/DeployingVMsWithTerraformInProxMox/#install-qemu-guest-agent-on-cloud-init-template
https://github.com/alexpdp7/alexpdp7
https://github.com/siderolabs/talos/discussions/6970

customization:
    systemExtensions:
        officialExtensions:
            - siderolabs/qemu-guest-agent

customization:


      "apt-get install -y wget",
      "wget -O /tmp/talos.raw.xz ${local.image}",
      "xz -d -c /tmp/talos.raw.xz | dd of=/dev/sda && sync",


# Ubuntu 20.04 AMD64 Packer Template

## Run examples

```bash
packer build -var-file=talos-1.7.4.pkrvars.hcl -var-file=example.pkrvars.hcl .
```
