#!/bin/bash

# Cron fix
my_path="$(dirname $0)"
cd "$my_path"

source configs.sh
source functions.sh

echo "INF: Initiate the restore"                                        | tee -a "$LOG"

FTP_FILES=`ftp_list_files`
backups=`echo "$FTP_FILES" | sort | grep '_backup.tar'`
configs=`echo "$FTP_FILES" | sort | grep '_etc.tar'`



#
# Stage 1 - Get the latest files for restore
#
ftp_latest_backup=$(echo "$backups" | tail -n 1)
ftp_latest_config=$(echo "$configs" | tail -n 1)



#
# Stage 2 - Restore files
#
echo "INF: Last backup is $ftp_latest_backup"                           | tee -a "$LOG"

echo "INF: Stop some services"                                          | tee -a "$LOG"
gitlab-ctl stop unicorn                                                 | tee -a "$LOG"
gitlab-ctl stop sidekiq                                                 | tee -a "$LOG"

echo "INF: Check the status"                                            | tee -a "$LOG"
gitlab-ctl status                                                       | tee -a "$LOG"

echo "INF: Copy backup from FTP to local path"                          | tee -a "$LOG"
cd /var/opt/gitlab/backups/
ftp -n $FTP_HOST << EOF                                                 | tee -a "$LOG"
quote USER $FTP_USER
quote PASS $FTP_PASS
cd $FTP_PATH_CONF
get $ftp_latest_backup
quit
EOF

# Parse the string
backup_date=`echo "$ftp_latest_backup" | awk -F '_gitlab' '{print $1}'` | tee -a "$LOG"

# This command will overwrite the contents of your GitLab database!
gitlab-rake gitlab:backup:restore BACKUP="$backup_date"

echo "INF: Start the GitLab"                                            | tee -a "$LOG"
gitlab-ctl start                                                        | tee -a "$LOG"

echo "INF: Run simple check"                                            | tee -a "$LOG"
gitlab-rake gitlab:check SANITIZE=true                                  | tee -a "$LOG"



#
# Stage 3 - Restore main configuration
#
if yesno --default no "Restore the /etc/gitlab configuration? [yes|no] ";
    then
        echo "INF: You answered yes"
    else
        echo "INF: You answered no"
        send_mail "restore" "$EMAIL" "$LOG"
        exit
fi

cd "$my_path"
ftp -n $FTP_HOST << EOF                                                 | tee -a "$LOG"
quote USER $FTP_USER
quote PASS $FTP_PASS
cd $FTP_PATH_MAIN
get $ftp_latest_config
quit
EOF
echo "INF: Extract the configs from archive"                            | tee -a "$LOG"
tar -xvpzf "$ftp_latest_config" -C /                                        | tee -a "$LOG"

echo "INF: Run simple check"                                            | tee -a "$LOG"
gitlab-ctl reconfigure                                                  | tee -a "$LOG"
send_mail "restore" "$EMAIL" "$LOG"
