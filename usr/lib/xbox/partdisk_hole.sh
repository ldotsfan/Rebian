#!/bin/sh

. /usr/lib/xbox/functions

LOGFILE=/tmp/install.log
FDISKSWAP=/usr/lib/xbox/make.fdisk.swap
FDISKROOT=/usr/lib/xbox/make.fdisk.root
#START=15657985
START=1
cleanup () {
	if [ -f $LOGFILE ]; then
		rm -f $LOGFILE
        fi
}
cleanup

$DIA --backtitle "Simple hd prtitioning (c) 2002 Edgar Hucek" --yesno "With this tool you can prepare a harddisk for the use with linux.\nIt creates a swap partition with the given size, takes the restspace behind the swap and makes an ext3 partition for using as rootfilesystem.\n( PART1 -> SWAP   )\n( PART2 -> ROOTFS )\nIf you have data on the disk make a BACKUP. Using this tool at your risk." 15 60 2>$LOGFILE
if [ "$?" == "1" ]; then
        cleanup
        exit 1
fi
DEVICE="/dev/hda"
$DIA --backtitle "Simple hd prtitioning (c) 2002 Edgar Hucek" --cancel-label "Cancel" --ok-label "Next" --inputbox "Swapsize ( example : +256M )" 8 40 +256M 2>$LOGFILE
if [ "$?" == "1" ]; then
        cleanup
        exit 1
fi
if [ "$?" == "0" ]; then
        SWAPSIZE=`cat $LOGFILE`
fi
if [ -e /dev/hda51 ]; then
	mkdir /tmp/target
	mount /dev/hda51 /tmp/target
	rm -f /tmp/target/xboxdash.xbe
	umount /tmp/target
fi
dd if=/dev/zero of=/dev/hda seek=0 bs=512 count=1 > /dev/null 2>&1
dd if=/dev/zero of=/dev/hda seek=1024 bs=512 count=1 > /dev/null 2>&1
dd if=/dev/zero of=/dev/hda seek=1537024 bs=512 count=1 > /dev/null 2>&1
dd if=/dev/zero of=/dev/hda seek=3073024 bs=512 count=1 > /dev/null 2>&1
dd if=/dev/zero of=/dev/hda seek=4609024 bs=512 count=1 > /dev/null 2>&1
dd if=/dev/zero of=/dev/hda seek=5633024 bs=512 count=1 > /dev/null 2>&1
dd if=/dev/zero of=/dev/hda seek=15633072 bs=512 count=1 > /dev/null 2>&1

echo "Make swap partition"
sed -e "s/@SIZE@/$SWAPSIZE/g" -e "s/@START@/$START/g" < $FDISKSWAP > /tmp/make.fdisk
fdisk $DEVICE < /tmp/make.fdisk > /dev/null 2>&1
rm -f /tmp/make.fdisk

echo "Make boot partition"
START=
sed -e "s/@SIZE@//g" -e "s/@START@/$START/g" < $FDISKROOT > /tmp/make.fdisk
fdisk $DEVICE < /tmp/make.fdisk > /dev/null 2>&1
rm -f /tmp/make.fdisk
echo "Make swap"
mkswap ${DEVICE}1
swapon ${DEVICE}1
echo "Make rootfs"
mkfs.ext3 ${DEVICE}2
tune2fs -c 0 ${DEVICE}2
exit 0
