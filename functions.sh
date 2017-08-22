#!/bin/bash

function send_mail {
    case "$1" in
        "ftp")
            echo "Script can't connect to FTP server" | mail -s "FTP server is DOWN" $2
        ;;
        "restore")
            cat "$3" | mail -s "Restore is complete" $2
        ;;
        "done")
            cat "$3" | mail -s "Backup is complete" $2
        ;;
    esac
}

function latest_backup {
    ls $BACKUP_PATH | sort | tail -n 1
}

function ftp_list_files {
ftp -n $FTP_HOST << EOF
quote USER $FTP_USER
quote PASS $FTP_PASS
ls $PATH_MAIN
ls $PATH_CONF
quit
EOF
}
