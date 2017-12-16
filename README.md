[![Build Status](https://www.travis-ci.org/joan-esteban/jebackup.svg?branch=master)](https://www.travis-ci.org/joan-esteban/jebackup)


# jebackup
Simple backup system based on tgz differentials written in bash. 


# Quick setup

### Fast setup for daily backups of home folder
- Copy sourcode on your system for instace `/opt/jebackup/`
- Create a file at `/etc/cron.daily/backup.sh`
- Give executions permissions: `chmod a+x /etc/cron.daily/backup.sh`
- Inside the file `backup.sh` put next code:
~~~
#!/bin/bash
/opt/jebackup/bin/jebackup.sh -s /home -d /mnt/NAS/backups -X "*.zip|*.rpm|*swp|*~|core" -f "%Y%m/%Y%m%d-%s"
~~~

This configuration make a full backup on the fist day of month, if you want a void this behaviour please change `"%Y%m/%Y%m%d-%s"`for `"%Y%m%d-%s"`  

# Usage



#### Please check build-in help
~~~
./bin/jebackup.sh -h
./bin/jebackup.sh -s <source_folder> -d <dest_folder> -v

 -c <config file>     : file with params
 -s <source_folder>   : folder that you want to backup (SOURCE_FOLDER)
 -d <dest_folder>     : where backup are stored (DEST_FOLDER)
 -r <result file>     : store result info at this file (RESULT_FILE)
 -X <exclude patterns>: list of patterns using pipe as field separator (EXCLUDE_PATTERNS_FROM_BACKUP)
 -f <pattern bck file>: pattern for filename ex:%Y%m%d-%s (GENERATED_BACKUP_FILE_PATTERN)
 -v                   : verbosity
 -u                   : dry-run
 -h                   : show help

~~~

# Credits
This software were developed by Joan Esteban for personal purposes, 
you can find latest version at githup [https://github.com/joan-esteban/jebackup](https://github.com/joan-esteban/jebackup).
For testing use [shunit2](https://github.com/kward/shunit2)

2017
