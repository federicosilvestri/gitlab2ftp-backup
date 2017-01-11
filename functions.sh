#!/bin/bash

function send_mail {
    case "$1" in
        "ftp")
            echo "Script can't connect to FTP server" | mail -s "FTP server is DOWN" -- "$2"
        ;;
        "done")
            cat "$3" | mail -s "Backup is complete" -- "$2"
        ;;
    esac
}

function latest_backup {
    ls /var/opt/gitlab/backups/ | sort | tail -n 1
}
