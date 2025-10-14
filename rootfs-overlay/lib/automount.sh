#!/bin/sh

{
  date
  echo "ACTION=$ACTION SUBSYSTEM=$SUBSYSTEM DEVNAME=$DEVNAME DEVPATH=$DEVPATH MDEV=$MDEV SEQNUM=$SEQNUM DISK_MEDIA_CHANGE=$DISK_MEDIA_CHANGE"
  echo "----"
} >> /var/log/mdev-cdrom.log

if [ "$ACTION" = "remove" ]; then
    if mountpoint -q "/media/$MDEV"; then
        umount "/media/$MDEV" 2>&1 && rmdir "/media/$MDEV"
    fi
elif [ "$ACTION" = "add" ]; then
    mkdir -p "/media/$MDEV"
    mount -o ro -t auto "/dev/$MDEV" "/media/$MDEV" || rmdir "/media/$MDEV"
fi
