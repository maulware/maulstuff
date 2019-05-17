#!/bin/sh
PREREQ="lvm"
prereqs()
{
     echo "$PREREQ"
}

case $1 in
prereqs)
     prereqs
     exit 0
     ;;
esac

. /usr/share/initramfs-tools/hook-functions
# Begin real processing below this line

echo "[I] Including what is required for shamir unseal"
copy_exec /bin/nc
copy_exec /usr/bin/ssh
copy_exec /usr/bin/sort
copy_exec /usr/bin/base64
copy_exec /usr/bin/passwd
copy_exec /usr/bin/ssss-combine

copy_exec /lib/libnss_compat.so.2
copy_exec /usr/lib/libz.so.1
copy_exec /etc/ld.so.cache
copy_exec /lib/i686/cmov/libutil.so.1

#create folders
mkdir -p "${DESTDIR}/etc/default/" "${DESTDIR}/etc/mboot" "${DESTDIR}/root/.ssh"

cp -pr /etc/default/nss "${DESTDIR}/etc/default/"
cp -pr /etc/nsswitch.conf  "${DESTDIR}/etc/"
cp -pr /etc/localtime  "${DESTDIR}/etc/"

# find libnss and use the folder with the most files.
libnsspath=$(find /lib/ -name "libnss_*" | xargs dirname | uniq -c | sort --numeric-sort | tail -1 | awk '{ print $2 }')
cp "${libnsspath}/"libnss_* "${DESTDIR}/lib/"

# specific known_host pattern to trust shamir-share-servers required to be set ouf of scope
if ! [ -f /etc/mboot/known_hosts ]; then
    echo "[W] no servers/CA known_hosts file, auto-unseal won't work if ssh_config does not have unsafe trust config"
fi

cp -r /etc/mboot/ ${DESTDIR}/etc/

#    cp /etc/mboot/boot_key ${DESTDIR}/mboot/

if ! [ -f /etc/mboot/ssh_config ]; then
    echo "[W] no explicit ssh_config given, some things might fail"
fi

if ! [ -f /etc/mboot/vars ]; then
    echo "[I] no vars file found for tweek setting"	
fi

if ! [ -f "${DESTDIR}/etc/passwd" ] || ! grep -q "root" "${DESTDIR}/etc/passwd"; then
  echo "root:x:0:0:root:/root:/bin/false" > "${DESTDIR}/etc/passwd"
fi

echo "[I] Finished with shamir unseal includes"
