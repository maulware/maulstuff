#!/bin/bash
#
# handle putting files where README.md is telling people to
#

if [[ $(whoami) != "root" ]]; then
    echo "Required to run as root to install config"
    exit 1
fi

# ensure tools are installed
apt install ssss coreutils

[[ ! -f /etc/initramfs-tools/hooks/mboot.sh ]] && cp hooks_mboot.sh /etc/initramfs-tools/hooks/mboot.sh
[[ ! -f /etc/initramfs-tools/scripts/local-top/mpremount.sh ]] && cp local-top_mpremount.sh /etc/initramfs-tools/scripts/local-top/mpremount.sh

chmod +x /etc/initramfs-tools/{hooks/mboot.sh,scripts/local-top/mpremount.sh}

# simply touch the file for easier later parameter setting by user
umask 077
mkdir /etc/mboot/
touch /etc/mboot/userdata

[[ ! -f /etc/mboot/mboot_key ]] && ssh-keygen -P '' -f /etc/mboot/boot_key -t ed25519
echo "Install on shamir servers: $(cat /etc/mboot/boot_key.pub)"

# not touching to allow errors if not created by user, as required:
echo "Add /etc/mboot/ssh_config (see README.md) and update-initramfs -u"

