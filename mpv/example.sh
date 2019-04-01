#!/bin/sh
#
# Example for sending IPC command to mpv socket
#
socket_dir="/tmp/mpvsocks"

for s in "${sock_dir}"/* ; do
    echo "$1" | socat - $s;
done
