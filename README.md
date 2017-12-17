[![Build Status](https://www.travis-ci.org/joan-esteban/jebackup.svg?branch=master)](https://www.travis-ci.org/joan-esteban/jebackup)


# jebackup v 0.9.5
Simple backup system based on tgz differentials written in bash. 

It is composed by two parts:
- jebackup.sh : Do the incremental backup in tgz files
- jerotate.sh : Take care of old backup removing it


# Quick setup

### Fast setup for daily backups of home folder
- Copy sourcode on your system for instace `/opt/jebackup/`
- Create a file at `/etc/cron.daily/backup.sh`
- Give executions permissions: `chmod a+x /etc/cron.daily/backup.sh`
- Inside the file `backup.sh` put next code:
~~~
#!/bin/bash
/opt/jebackup/bin/jebackup.sh -s /home -d /mnt/NAS/backups -X "*.zip|*.rpm|*swp|*~|core" -f "%Y%m/%Y%m%d-%s"
/opt/jesteban/bin/jerotate.sh -d /mnt/NAS/backups  -m maximum_size -a remove -s ROTATE_MAXIMUM_SIZE_TARGET_MB=50000 -s NO_REMOVE_FILES_NEWER_THRESHOLD_SECONDS=3600 -s RECURSIVE_BACKUP_FILES=1
~~~

This configuration make:
-  A full backup on the fist day of month, if you want a void this behaviour please change `"%Y%m/%Y%m%d-%s"`for `"%Y%m%d-%s"`  
- Keep yours backups under 50.000 Mb (5Gb) preventing to erase files created 1h ago

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
And:
~~~
./bin/jerotate.sh -s <source_folder> -d <dest_folder> -v
 
 -c <config file>     : file with params
 -d <dest_folder>     : where backup are stored (DEST_FOLDER)
 -m <method>          : how do you want to control size? (METHOD_ROTATE)
                          maximum_size : it keep under maximum size (need ROTATE_MAXIMUM_SIZE_TARGET)
                          none : 
 -a <discard_method>  : what to do to discards backups?
                          none : look away and whistle
                          remove : discard marked backup removing
 -s <VAR=VALUE>       : Set especific value Ex: ROTATE_MAXIMUM_SIZE_TARGET_MB=4
 -v                   : verbosity
 -u                   : dry run
 -h                   : show help

~~~

# Credits
This software were developed by Joan Esteban for personal purposes, 
you can find latest version at githup [https://github.com/joan-esteban/jebackup](https://github.com/joan-esteban/jebackup).
For testing used [shunit2](https://github.com/kward/shunit2)

2017
