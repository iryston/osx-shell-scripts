#!/bin/bash

# file ramdisk-for-osx.sh
# Create, unmount and recreate a ramdisk in OS X
# Usage: ramdisk-for-osx.sh [start|stop|restart]

# mount point for the ramdisk volume
ramdisk='/Volumes/RAMD'
# size of created disk in MB
disk_size=2048

# compute the size of the disk in 512-byte sectors
# rdsize=$(($disk_size*1024*1024/512))
rdsize=$(($disk_size*2048))

StartService () {
  cmd="\$3 == \"$ramdisk\" {print \$3}"
  if [[ $(mount | awk "$cmd") != "" ]]; then
    echo "$ramdisk is already mounted."
  else
    # create disk
    diskutil erasevolume HFS+ "ramdisk" `hdiutil attach -nobrowse -nomount ram://$rdsize`
  fi
}

StopService () {
  cmd="\$3 == \"$ramdisk\" {print \$3}"
  if [[ $(mount | awk "$cmd") != "" ]]; then
    # eject disk
    hdiutil detach $ramdisk
  else
    echo "$ramdisk is not mounted"
  fi
}

RestartService () {
  cmd="\$3 == \"$ramdisk\" {print \$3}"
  if [[ $(mount | awk "$cmd") != "" ]]; then
    # eject disk
    hdiutil detach $ramdisk
    # create disk
    diskutil erasevolume HFS+ "ramdisk" `hdiutil attach -nobrowse -nomount ram://$rdsize`
  else
    echo "$ramdisk is not mounted"
    # create disk
    diskutil erasevolume HFS+ "ramdisk" `hdiutil attach -nobrowse -nomount ram://$rdsize`
  fi
}

# Test for arguments.
if [ -z $1 ]; then
  echo "Usage: $0 [start|stop|restart] "
  exit 1
fi

# Source the common setup functions for startup scripts
test -r /etc/rc.common || exit 1
. /etc/rc.common

RunService "$1"
