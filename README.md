# GitLab backuper

Collection of scripts for make GitLab backups and pushing to FTP server

## Automate it

You can automate packages update via Cron, for example:
    
    # Run backup
    0 2 * * * /path/to/backuper/backup.sh

__Warning: Absolute path is important!__

This example mean: "Run script every day at 2 hour 0 minutes", more details you can find on [Wikipedia](https://en.wikipedia.org/wiki/Cron#Overview).
