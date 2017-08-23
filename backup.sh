#!/bin/bash

# Cron fix
my_path="$(dirname $0)"
cd "$my_path"

# Require files
source configs.sh
source functions.sh

#
# Step 1 - Check for ftp server
#
if [ exec 6<>"/dev/tcp/$FTP_HOST/$FTP_PORT" ]
	then
		
		echo "INF: FTP server is UP" | tee -a "$LOG"
		exec 6>&- # close output connection
		exec 6<&- # close input connection
		
		else
			echo "ERR: FTP server is DOWN" | tee -a "$LOG"
			send_mail "ftp" "$EMAIL"
			exit
fi

#
# Step 2 - Create the backup via gitlab-rake
#
echo "INF: Initiate the backup by gitlab-rake"   | tee -a "$LOG"
/opt/gitlab/bin/gitlab-rake gitlab:backup:create | tee -a "$LOG"

currentDataBackup=`latest_backup`
x=1

ls -t $BACKUP_PATH/$BACKUP_FILEMASK | grep -v "$currentDataBackup" | \
while read filename
	do
		if [ $x -le $BACKUP_KEEP ]
			then
				x=$(($x+1))
				continue
		fi
		echo "INF: Remove $filename"
		rm $filename
done

# Copy archive to temporary location to allow FTP loading
cp $BACKUP_PATH/$currentDataBackup .

#
# Step 3 - Create the backup of confis
#
confArchiveBackup=$(date "+%s_%Y_%m_%d_gitlab_etc.tar.gz")
tar -cvpzf "$confArchiveBackup" /etc/gitlab/ 

#
# Step 4 - Push latest backup to ftp server
#
ftp -n $FTP_HOST << EOF | tee -a "$LOG"
quote USER $FTP_USER
quote PASS $FTP_PASS
cd $FTP_PATH_MAIN
put $currentDataBackup
cd $FTP_PATH_CONF
put $confArchiveBackup
quit
EOF

#
# Step 5 - Clean up
#
rm -v "$confArchiveBackup" | tee -a "$LOG"
rm -v "$currentDataBackup" | tee -a "$LOG"

#
# Step 6 - All done, send message with log file to owner
#
send_mail "done" "$EMAIL" "$LOG"
