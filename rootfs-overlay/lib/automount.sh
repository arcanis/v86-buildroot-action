#!/usr/bin/sh

if [ "$ACTION" = "remove" ]; then
    if mountpoint -q "/media/$MDEV"; then
        umount "/media/$MDEV" 2>&1 && rmdir "/media/$MDEV"
    fi
elif [ "$ACTION" = "add" ]; then
    mkdir -p "/media/$MDEV"
    mount "/dev/$MDEV" "/media/$MDEV" || rmdir "/media/$MDEV"
fi
