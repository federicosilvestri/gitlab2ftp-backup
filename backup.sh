#!/bin/bash

# Cron fix
my_path="$(dirname $0)"
cd "$my_path"

source configs.sh
source functions.sh

#
# Step 1 - Check for ftp server
#
if [ exec 6<>"/dev/tcp/$FTP_HOST/$FTP_PORT" ]
    then
        echo "INF: FTP server is UP"                | tee -a "$LOG"
        exec 6>&- # close output connection
        exec 6<&- # close input connection
    else
        echo "ERR: FTP server is DOWN"              | tee -a "$LOG"
        send_mail "ftp" "$EMAIL"
        exit
fi

#
# Step 2 - Create the backup via gitlab-rake
#
/opt/gitlab/bin/gitlab-rake gitlab:backup:create    | tail -a "$LOG"

#
# Step 3 - Create the backup of confis
#
FILE_CONF=$(date "+%s_%Y_%m_%d_gitlab_etc.tar")
tar -cf "$FILE_CONF" -C / etc/gitlab

#
# Step 4 - Push latest backup to ftp server
#
FILE_MAIN=`latest_backup`
ftp -n $FTP_HOST << EOF                             | tee -a "$LOG"
quote USER $FTP_USER
quote PASS $FTP_PASS
cd $PATH_MAIN
put $FILE_MAIN
cd $PATH_CONF
put $FILE_CONF
quit
EOF
# Remove the config backup
rm -v "$FILE_CONF"                                  | tee -a "$LOG"

#
# Step 5 - All done, send message with log file to owner
#
send_mail "done" "$EMAIL" "$LOG"
