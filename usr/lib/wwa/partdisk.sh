#!/bin/sh
LOGFILE=/tmp/install.log
FDISKTMPL=/usr/lib/wwa/make.fdisk.template
START=1
cleanup () {
	if [ -f $LOGFILE ]; then
		rm -f $LOGFILE
        fi
}
cleanup

dialog --backtitle "Simple hd prtitioning (c) 2002 Edgar Hucek" --yesno "With this tool you can prepare a harddisk for the use with linux.\nIt creates a swap partition with the given size, takes the restspace behind the swap and makes an ext3 partition for using as rootfilesystem.\n( PART1 -> SWAP   )\n( PART2 -> ROOTFS )\nIf you have data on the disk make a BACKUP. Using this tool at your risk." 15 60 2>$LOGFILE
if [ "$?" == "1" ]; then
        cleanup
        exit 0
fi

dialog --backtitle "Simple hd prtitioning (c) 2002 Edgar Hucek" --cancel-label "Cancel" --ok-label "Next" --inputbox "Device ( example : /dev/hda )" 8 40 /dev/hda 2>$LOGFILE
if [ "$?" == "1" ]; then
        cleanup
        exit 0
fi
if [ "$?" == "0" ]; then
        DEVICE=`cat $LOGFILE`
fi
dialog --backtitle "Simple hd prtitioning (c) 2002 Edgar Hucek" --cancel-label "Cancel" --ok-label "Next" --inputbox "Swapsize ( example : +256M )" 8 40 +256M 2>$LOGFILE
if [ "$?" == "1" ]; then
        cleanup
        exit 0
fi
if [ "$?" == "0" ]; then
        SWAPSIZE=`cat $LOGFILE`
fi
echo "d
1
d
2
d
3
d
4
w" > /tmp/make.fdisk
fdisk $DEVICE < /tmp/make.fdisk > /dev/null 2>&1
sed -e "s/@SWAPSIZE@/$SWAPSIZE/g" -e "s/@START@/$START/g" < $FDISKTMPL > /tmp/make.fdisk
fdisk $DEVICE < /tmp/make.fdisk > /dev/null 2>&1
rm -f /tmp/make.fdisk
mkswap ${DEVICE}1 > /dev/null 2>&1
mkfs.ext3 ${DEVICE}2 > /dev/null 2>&1
