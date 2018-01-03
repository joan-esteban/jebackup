#!/bin/bash

source $(dirname $0)/cfg.sh

SNAPSHOT=${JEBACKUP_BINS}/jebackup.sh
JEROTATE=${JEBACKUP_BINS}/jerotate.sh
DATASET=$(dirname $0)/dataset

source ${JEBACKUP_LIBS}/ansicolors.sh
source ${JEBACKUP_LIBS}/logger.sh


function setUp(){
	__TMP_FOLDER_BACKUPS=$(mktemp -d)
	VERBOSE "setting up test: created empty folder to store backups: $__TMP_FOLDER_TO_STORE_BACK"
	
	
}

function tearDown(){
	if [ ! -z $__TMP_FOLDER_BACKUPS ]; then
		VERBOSE "tearing down test: erasing $__TMP_FOLDER_BACKUPS"
		rm -Rf $__TMP_FOLDER_BACKUPS
	fi
}

# $1 -> file
# $2 -> size kb
function inflate_file_size(){
	local __FILE="$1"
	local __KB="$2"
	dd if=/dev/zero of=$__FILE bs=1024 count=$__KB 2>&1 | LOG_OUTPUT_FILTER  
	
	
}

# it simulate files without extra folders
# simulate a dialy backup with a fresh backup made right now
# 5 files of 3 Mb
#[OUT  ] -rw-rw-r-- 1 zodiac zodiac 3,0M dic 13 11:13 backup-20171213-1513160021.tgz
#[OUT  ] -rw-rw-r-- 1 zodiac zodiac 3,0M dic 14 11:13 backup-20171214-1513246421.tgz
#[OUT  ] -rw-rw-r-- 1 zodiac zodiac 3,0M dic 15 11:13 backup-20171215-1513332821.tgz
#[OUT  ] -rw-rw-r-- 1 zodiac zodiac 3,0M dic 16 11:13 backup-20171216-1513419221.tgz
#[OUT  ] -rw-rw-r-- 1 zodiac zodiac 3,0M dic 17 11:13 backup-20171217-1513505621.tgz
#[OUT  ] -rw-rw-r-- 1 zodiac zodiac 20K dic 17 11:13 master.incremental

function inflate_fake_backup_plain_folder(){
	inflate_file_size $__TMP_FOLDER_BACKUPS/master.incremental 20
	local __TSTAMP=$(date +%s)
	for I in $(seq 1 5); do
		local __FILE=$(date -d @${__TSTAMP} +backup-%Y%m%d-%s.tgz)
		
		inflate_file_size $__TMP_FOLDER_BACKUPS/${__FILE} 3072
		touch -m -d "@${__TSTAMP}" $__TMP_FOLDER_BACKUPS/${__FILE}
		__TSTAMP=$((__TSTAMP - 86400))
		
	done
	ls -lah $__TMP_FOLDER_BACKUPS 2>&1 | LOG_OUTPUT_FILTER 
	VERBOSE folder [$__TMP_FOLDER_BACKUPS] size $(du -hs $__TMP_FOLDER_BACKUPS )
	
}

###############################################################################
# TEST
###############################################################################
function DISABLED_test_fails_params() {
	
	 
	$JEROTATE -k  
	assertEquals $? 1
}

function test_maximum_size_method_doesnt_count_no_backup_files() {
	inflate_fake_backup_plain_folder
	inflate_file_size $__TMP_FOLDER_BACKUPS/no_back_file_of_5mb 5000
	inflate_file_size $__TMP_FOLDER_BACKUPS/another_tgz_but_is_not_a_backup.tgz 5000
	$JEROTATE  -d $__TMP_FOLDER_BACKUPS -m maximum_size -s ROTATE_MAXIMUM_SIZE_TARGET_MB=3 -s NO_REMOVE_FILES_NEWER_THRESHOLD_SECONDS=120  -s RECURSIVE_BACKUP_FILES=0 -s PATTERN_BACKUP_FILES='backup-*.tgz' -v -r ${__TMP_FOLDER_BACKUPS}/results  -a remove
	assertEquals "jerotate returns error" $? 0
	VERBOSE "RESULT FILE:" 
	VERBOSE "=================================="
	cat  ${__TMP_FOLDER_BACKUPS}/results | LOG_OUTPUT_FILTER 
	VERBOSE "----------------------------------[END RESULTS]"
	. ${__TMP_FOLDER_BACKUPS}/results
	# Output files have next vars:
	# RESULT_ROTATE_ORIGINAL_SIZE_BACKUP_MB
	# RESULT_ROTATE_REDUCED_SIZE_BACKUP_MB
	# RESULT_ROTATE_REMOVE_FILES
	# RESULT_ROTATE_GOAL_ACHIEVE
	
	assertEquals $RESULT_ROTATE_ORIGINAL_SIZE_BACKUP_MB "15"
}

set_logger_level $LOG_LEVEL_WARNING_CTE
set_logger_level $LOG_LEVEL_VERBOSE_CTE
source $SHUNIT2

