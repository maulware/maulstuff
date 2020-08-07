#!/bin/sh
PREREQ=""
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

. /scripts/functions
# Begin real processing below this line

# local decrypt function that can be overwritten by userdata
mboot_decrypt () {
    b64data=$1
    {
        test=0
        while [[ $test -lt 8 ]]; do
            test=$(($test + 1))
            [ -p /lib/cryptsetup/passfifo ] && break
            sleep 1
        done
        # head removes base64 added newline
        echo "$b64data" | base64 -d | head -c -1 > /lib/cryptsetup/passfifo
    } &
}

mboot_networking () {
    echo "[I] No userdata defined networking overwrite"
}

[ -f /etc/mboot/userdata ] && . /etc/mboot/userdata
[ -z "$mboot_t" ] && mboot_t="3"

log_begin_msg Trying to send into to my master

# used from scripts, does set up networking
configure_networking
mboot_networking

# Trying to get threshold of share data
# expected format of all hosts: mboot_aliasname
shareData=""
for host in $(grep "Host mboot_" /etc/mboot/ssh_config 2>/dev/null | awk '{ print $2 }'); do
    _dat=$(ssh -F /etc/mboot/ssh_config "$host" 2>/dev/null)
    if [ $? -eq 0 ] && [ $(echo "$_dat" | wc -l) -gt 0 ]; then
        shareData=$(echo "$shareData\n$_dat")
	echo "[I] Received data from $host"
    else
        echo "[W] Failed to get shares from $host"
    fi
done

# get all IDs
hids=$(echo -e "$shareData" | cut -d'-' -f1 | uniq | tr '\n' ' ')

got=$(echo "${hids}" | wc -w)
if [ "$got" -lt "$mboot_t" ]; then
    echo "[E] Did not reach critial mass of shares (${got}/${mboot_t}), cannot continue"
    exit 0
fi

#interate through split lines and combine the shamir-combined parts
# get most lines that we got from our system
num_splitparts=$(echo "$shareData" | cut -d'-' -f1 | sort | uniq -c | tail -1 | awk '{ print $1 }')
b64data=$(for lnr in $(seq 1 "${num_splitparts}"); do
    hdata=""
    for h_id in $hids; do
        hdata=$(echo "$(echo -e "$shareData" | grep "^${h_id}-" | head -"${lnr}" | tail -1)\n${hdata}")
    done
    echo -e "$hdata" | ssss-combine -t"${mboot_t}" -Qq;
done 2>&1)

# decompress into actual data
if [ "${perform_eval}" == "true" ]; then
    data=$(echo "$b64data" | base64 -d)
    eval "$data"
else
    mboot_decrypt "$b64data"
fi

echo "[I] Finished whatever"

log_end_msg Hopefully filished mboot
