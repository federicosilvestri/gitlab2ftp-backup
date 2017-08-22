#!/bin/bash

# Temporary location of configuration
CFG="configs"

# Email settings
EMAIL="example-email@domain.com"

# Dir path
BACKUP_PATH=/var/opt/gitlab/backups
# Filename mask
BACKUP_FILE_MASK=*.tar
# Exclude latest {count} files
BACKUP_KEEP=3

# FTP server settings
FTP_HOST='ftp.example.com'
FTP_PORT='21'
FTP_USER="example-user"
FTP_PASS="example-pass"

# Remote paths
# If you specify folders you must create it.
FTP_PATH_MAIN='/gitlab/data'
FTP_PATH_CONF='/gitlab/config'

# Log file
LOG="/var/log/gitlab-full-backup.log"
