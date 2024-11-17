#!/bin/sh

set -ex

rc-service sshd stop

# Set script variables from packer
SSH_PUBLIC_KEY="ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAFY8rg0/PYGCS3aHtNriO0Pb6nAAXPVTQg4gbO8w8APx0JIRWKbnAWoTef/femIAjYZWflYDvfGNzDjQ34ZRPhoigF5c4LdAUMB9NSCHYke+hNS1HHSpXvdg6ZEMfrDUalTzGq9yovmVA3C912lwWbiptpfd7NN6jGgihYVmdzroILTgg== admin@apollo"
USE_PUBLIC_KEY_AUTH="true"
USE_OPENSSH_PAM="true"

# Update apk repositories
sed -r -i '\|/v[0-9]+\.[0-9]+/community|s|^#\s?||g' /etc/apk/repositories
apk update

# Add qemu-guest-agent
apk add qemu-guest-agent
echo -e GA_PATH="/dev/vport2p1" >> /etc/conf.d/qemu-guest-agent
rc-update add qemu-guest-agent
rc-service qemu-guest-agent restart



# Add root user authorized_keys
if [ "$USE_PUBLIC_KEY_AUTH" = "true" ]
then
  mkdir ~/.ssh
  chmod 700 ~/.ssh
  echo $SSH_PUBLIC_KEY >> ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
fi

# Update ssh configuration
if [ "$USE_PUBLIC_KEY_AUTH" = "true" ]
then
  sed -r -i "s/^#?PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
  sed -r -i "s/^#?PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config
  sed -r -i "s/^#?PermitRootLogin.*/PermitRootLogin prohibit-password/g" /etc/ssh/sshd_config
else
  sed -r -i "s/^#?PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
  sed -r -i "s/^#?PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
fi

# Use PAM version of openssh
if [ "$USE_OPENSSH_PAM" = "true" ]
then
  apk add openssh-server-pam
  rm /usr/sbin/sshd
  ln -s /usr/sbin/sshd.pam /usr/sbin/sshd
  sed -r -i "s/^#?UsePAM.*/UsePAM yes/g" /etc/ssh/sshd_config
fi

apk add make jq

rc-service sshd restart
