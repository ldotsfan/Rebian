#!/bin/sh

TARGET=$1

if [ "$TARGET" == "" ]; then
	echo "No part target"
fi

. /usr/lib/xbox/functions

LOGFILE=/tmp/install.log
cleanup () {
	if [ -f $LOGFILE ]; then
		rm -f $LOGFILE
        fi
}
cleanup

$DIA --backtitle "Simple fs creation (c) 2002 Edgar Hucek" --yesno "With this tool you can prepare a harddisk for the use with linux.\nIt creates a swap file and an rootfilesystemi file on an fatx partition.\nIf you have data on the disk make a BACKUP. Using this tool at your risk.\n" 15 60 2>$LOGFILE
if [ "$?" == "1" ]; then
        cleanup
        exit 1
fi
DEVICE="/dev/hda"
$DIA --backtitle "Simple fs creation (c) 2002 Edgar Hucek" --cancel-label "Cancel" --ok-label "Next" --inputbox "Swapsize in Megabytes ( example : 256 )" 8 40 256 2>$LOGFILE
if [ "$?" == "1" ]; then
        cleanup
        exit 1
fi
if [ "$?" == "0" ]; then
        SWAPSIZE=`cat $LOGFILE`
fi
$DIA --backtitle "Simple fs creation (c) 2002 Edgar Hucek" --cancel-label "Cancel" --ok-label "Next" --inputbox "Rootfilesystemsize in Megabytes ( example : 2000 )" 8 40 2000 2>$LOGFILE
if [ "$?" == "1" ]; then
        cleanup
        exit 1
fi
if [ "$?" == "0" ]; then
        ROOTSIZE=`cat $LOGFILE`
fi
modprobe fatx > /dev/null 2>&1
mkdir -p /tmp/target
mount -t fatx $TARGET /tmp/target
cd /tmp/target
if [ -f debian ];then
	rm -f debian
fi
mkdir debian
cd debian
echo "Make swap file"
dd if=/dev/zero of=swap count=$SWAPSIZE bs=1024k
echo "Make swap"
mkswap swap
swapon swap
echo "Make root file"
dd if=/dev/zero of=rootfs count=$ROOTSIZE bs=1024k
losetup /dev/loop/7 rootfs
echo "Make rootfs"
mkfs.ext3 /dev/loop/7
tune2fs -c 0 /dev/loop/7
losetup -d /dev/loop/7
cd /
#umount /tmp/target
exit 0
