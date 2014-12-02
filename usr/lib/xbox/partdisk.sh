#!/bin/sh

. /usr/lib/xbox/functions

LOGFILE=/tmp/install.log
FDISKSWAP=/usr/lib/xbox/make.fdisk.swap
FDISKROOT=/usr/lib/xbox/make.fdisk.root
#START=15657985
START=15633072
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
echo "d
1
d
2
d
10
d
9
d
8
d
7
d
6
d
5
d
3
d
4
w" > /tmp/make.fdisk
dd if=/dev/zero of=/dev/hda seek=15633072 bs=512 count=1 > /dev/null 2>&1
fdisk $DEVICE < /tmp/make.fdisk > /dev/null 2>&1
echo "Make swap partition"
sed -e "s/@SIZE@/$SWAPSIZE/g" -e "s/@START@/$START/g" < $FDISKSWAP > /tmp/make.fdisk
fdisk -u $DEVICE < /tmp/make.fdisk > /dev/null 2>&1
rm -f /tmp/make.fdisk

START=`fdisk -u -l ${DEVICE} | grep ${DEVICE}1 | awk -F' ' '{ print $3; }'`
START=`expr $START + 1`
echo "Make boot partition"
sed -e "s/@SIZE@//g" -e "s/@START@/$START/g" < $FDISKROOT > /tmp/make.fdisk
fdisk -u $DEVICE < /tmp/make.fdisk > /dev/null 2>&1
rm -f /tmp/make.fdisk
echo "Make swap"
mkswap ${DEVICE}1
swapon ${DEVICE}1
echo "Make rootfs"
mkfs.ext3 ${DEVICE}2
tune2fs -c 0 ${DEVICE}2
exit 0
