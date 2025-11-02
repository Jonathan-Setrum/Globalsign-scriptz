#!/bin/bash

# Script Loc: /home/admin/tsav4_db_archive.sh

dt=`date +%Y%m%d`
output=/tmp/tsav4_db_archive-$dt.log
loc='/var/lib/pgsql'
dbowner=signserverv4
host=`echo $HOSTNAME | awk -F '.' '{print $1}'`
tsadb=("signserverv4" "signserverv4_1")

cmd='sudo -i -u postgres psql'

rm -f $output
# check if DB is master
if echo "select pg_is_in_recovery()" | $cmd | grep -q 'f' ; then
	echo "## Database is in 'Master' state, proceeding!" | tee -a $output
else
	echo "## Datebase is in 'Standby' state, quiting!" | tee -a $output
	exit
fi

# get current signserver db name
echo "postgres=# \l+" | tee -a $output
echo "`echo "\l+" | $cmd | grep signserverv4 | tee -a $output`"
echo "" | tee -a $output

curdb=`echo "\l" | $cmd | awk '{print $1}' | grep signserverv4`
echo "Current DB: $curdb" | tee -a $output

if [ "$curdb" == "${tsadb[0]}" ]; then
	newdb="${tsadb[1]}"
	echo "New DB: $newdb" | tee -a $output
elif [ "$curdb" == "${tsadb[1]}" ]; then
	newdb="${tsadb[0]}"
	echo "New DB: $newdb" | tee -a $output
else
	echo "Could not datermind current DB name, quiting!" | tee -a $output
	exit
fi

# Create new DB and migrate data (exclude tables 'auditrecorddata' & 'archivedata') if user proceed
echo "" | tee -a $output
echo "Create new DB '$newdb', migrate schema and data from current db '$curdb'" | tee -a $output
read -p "Proceed? [y/n]:" input
echo "" | tee -a $output

if [ "$input" == "y" ]; then
	echo "## Note: if failed on process, use below command to delete new db: $newdb" | tee -a $output
	echo "echo \"drop database $newdb\" | $cmd" | tee -a $output
	echo "" | tee -a $output
	sleep 3

	echo "## Dump current DB to $loc/$curdb""_bak.sql exclude tables 'auditrecorddata' & 'archivedata'" | tee -a $output
	if sudo -i -u postgres pg_dump $curdb --exclude-table-data='auditrecorddata' --exclude-table-data='archivedata' > $loc/$curdb\_bak.sql; then
		echo "Successful!" | tee -a $output
	else
		echo "Failed, quiting!" | tee -a $output
		exit
	echo "" | tee -a $output
	fi

	echo "## Create new DB: $newdb" | tee -a $output
	if echo "create database $newdb owner $dbowner" | $cmd ; then
		echo "Successful!" | tee -a $output
	else
		echo "Failed, quiting!" | tee -a $output
		exit
	echo "" | tee -a $output
	fi

	echo "## Grant access to owner $dbowner" | tee -a $output
	echo "GRANT ALL PRIVILEGES ON DATABASE $newdb TO $dbowner;"
	if echo "GRANT ALL PRIVILEGES ON DATABASE $newdb TO $dbowner" | $cmd ; then
		echo "Successful!" | tee -a $output
	else
		echo "Failed, quiting!" | tee -a $output
		exit
	echo "" | tee -a $output
	fi

	echo "## Import backup DB to new DB: $newdb" | tee -a $output
	if $cmd $newdb < $loc/$curdb\_bak.sql ; then
		echo "Successful!" | tee -a $output
	else
		echo "Failed, quiting!" | tee -a $output
		exit
	echo "" | tee -a $output
	fi

	echo "" | tee -a $output
	echo "$newdb=# \d+" | tee -a $output
	echo "\d+" | $cmd $newdb | tee -a $output

	echo "" | tee -a $output
	echo "----------------------------------------------------------------------------" | tee -a $output
	echo "New db: '$newdb' created and data migrated (exclude tables: archivedata & auditrecorddata)" | tee -a $output
	echo "Proceed with below procedures:" | tee -a $output
	echo "" | tee -a $output
	echo "Server: sg-tsa3 ~ 1" | tee -a $output
	echo "Carry out below steps on Servers one by one!" | tee -a $output
	echo "Modify in standalone.xml to point to new DB: '$newdb'" | tee -a $output
	echo "# vim /opt/wildfly/default/standalone/configuration/standalone.xml" | tee -a $output
	echo "Change old DB: $curdb to new DB: $newdb name in below line:" | tee -a $output
	echo "<connection-url>jdbc:postgresql://172.18.8.233:5432/$curdb?preferQueryMode=simple</connection-url>" | tee -a $output
	echo "To:" | tee -a $output
	echo "<connection-url>jdbc:postgresql://172.18.8.233:5432/$newdb?preferQueryMode=simple</connection-url>" | tee -a $output
	echo "Restart 'wildfly' service and verify status in log" | tee -a $output
	echo "# service wildfly restart && tail -f /data/wildfly/log/server.log" | tee -a $output
	echo "" | tee -a $output
	echo "Server: $host (Current Master)" | tee -a $output
	echo "Verify client traffic to new db: '$newdb' and old db: '$curdb'." | tee -a $output
	echo "# sudo -i -u postgres psql -c \"select * from pg_stat_activity where datname = '$newdb'\"" | tee -a $output
	echo "# sudo -i -u postgres psql -c \"select * from pg_stat_activity where datname = '$curdb'\"" | tee -a $output
	echo "All client traffic should go to new db: '$newdb', proceed if 'No' client traffic go to old db: '$curdb'" | tee -a $output
	echo "" | tee -a $output
	echo "Server: sg-mrbkdb (backup)" | tee -a $output
	echo "# su - postgres -c \"nohup pg_dump $curdb | gzip -9 > /data/backup/$curdb.$dt.sql.gz &\"" | tee -a $output
	echo "After backup completed, verify backup file is readable and size is reasonable." | tee -a $output
	echo "# zcat /data/backup/$curdb.$dt.sql.gz | head -n 20" | tee -a $output
	echo "" | tee -a $output
	echo "Server: $host (Current Master)" | tee -a $output
	echo "drop old db: '$curdb' and check free space afterward 'df -h | grep '/data'." | tee -a $output
	echo "# echo \"drop database $curdb\" | $cmd" | tee -a $output
	echo "# echo \"\l+\" | sudo -i -u postgres psql" | tee -a $output
	echo ""
	echo "Script log saved at $output"

else
	echo "User stopped proceeding!" | tee -a $output
fi
