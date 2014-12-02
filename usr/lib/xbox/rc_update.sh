#!/bin/sh

UPDATE="/usr/sbin/update-rc.d"

update_rc() {
	$UPDATE -f xfs $1
	$UPDATE -f lpd $1
	$UPDATE -f sysklogd $1
	$UPDATE -f klogd $1
	$UPDATE -f atd $1
	$UPDATE -f cron $1
	$UPDATE -f inetd $1
}

case "$1" in
	add)
		echo "Adding scripts"
		update_rc defaults
		;;
	remove)
		echo "Removing scripts"
		update_rc remove
		;;
	*)
		echo "Usage $0 {add|remove}"
		;;
esac
