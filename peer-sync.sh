#!/bin/bash

host=`echo $HOSTNAME | awk -F '.' '{print $1}'`
dt=`date +%Y%m%d-%H%M%S`
id=1897200368
cmd="/opt/ejbca/default/bin/ejbca.sh peer"
lock=/tmp/peer-sync.lock
out=/tmp/peer-sync.status
result=/var/log/peer-sync.log

if [ ! -f $lock ]; then
	$cmd list | grep $id > $out
	echo $dt >> $result
	if grep -q -e "No synchronization in progress" -e "Cancelled" $out; then
		touch $lock
		echo "$cmd sync --id $id --do-not-push-cert --do-not-push-integrity" >> $result
		$cmd sync --id $id --do-not-push-integrity
	elif grep -q "Failure" $out; then
		cat $out >> $result
		echo "" >> $result
	fi
	while true; do
		sleep 10
		$cmd list | grep $id > $out
		if grep -q "Running" $out; then
			sleep 300
		else
			echo $dt >> $result
			cat $out >> $result
			echo "" >> $result
			break
		fi
	done
#cat $out | mail -s "Peer sync result - $host" infrastructure@globalsign.com
rm -f $lock $out
fi
