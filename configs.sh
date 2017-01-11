#!/bin/bash

# Temporary location of configuration
CFG="configs"

# Email settings
EMAIL="mail@example.com"

# FTP server settings
FTP_HOST='ftp.debian.org'
FTP_PORT='21'
FTP_USER="user"
FTP_PASS="pass"

# Paths on FTP (should be absolute)
PATH_MAIN='/gitlab/main_bk/'
PATH_CONF='/gitlab/configs_bk/'

# The log file
LOG="$(pwd)/logs/$(date +%Y-%m-%d).log"
