#!/bin/bash

source $(dirname $0)/cfg.sh

SNAPSHOT=${JEBACKUP_BINS}/jebackup.sh
DATASET=$(dirname $0)/dataset

source ${JEBACKUP_LIBS}/ansicolors.sh
source ${JEBACKUP_LIBS}/logger.sh


function filter_progress(){
	echo -n  "PROGRESS: " >&2
	while read A; do
		echo -n "." >&2
	done
	echo " " >&2
}



function setUp(){
	__TMP_DATA_TO_BACK=$(mktemp -d)
	VERBOSE "setting up test: copying data to: $__TMP_DATA_TO_BACK"
	cp -av ${DATASET}/set1 $__TMP_DATA_TO_BACK > /dev/null 2>&1
	
	__TMP_FOLDER_TO_STORE_BACK=$(mktemp -d)
	VERBOSE "setting up test: created empty folder to store backups: $__TMP_FOLDER_TO_STORE_BACK"

	__TMP_WORKING_FOLDER=$(mktemp -d)
	VERBOSE "setting up test: created empty folder for temporal work: $__TMP_WORKING_FOLDER"

}

function tearDown(){
	if [ ! -z $__TMP_DATA_TO_BACK ]; then
		VERBOSE "tearing down test: erasing $__TMP_DATA_TO_BACK"
		rm -Rf $__TMP_DATA_TO_BACK
	fi
	if [ ! -z $__TMP_FOLDER_TO_STORE_BACK ]; then
		VERBOSE "tearing down test: erasing $__TMP_FOLDER_TO_STORE_BACK"
		rm -Rf $__TMP_FOLDER_TO_STORE_BACK
	fi
	if [ ! -z $__TMP_WORKING_FOLDER ]; then
		VERBOSE "tearing down test: erasing $__TMP_WORKING_FOLDER"
		rm -Rf $__TMP_WORKING_FOLDER
	fi

}

# $1-> folder 1
# $2-> folder 2
# rest -> extra params for diff
function check_contents_folder_equals(){
	local _F1=$1
	local _F2=$2
	shift 2
	diff -r $* "$_F1" "$_F2" 
}

# $1 -> dest_folder
# $2-... -> tgz 
function untar_tgzs(){
	local __DEST_FOLDER="$1"
	local __TGZ
	shift
	pushd $__DEST_FOLDER > /dev/null 2>&1
	for __TGZ in $*; do
		VERBOSE untaring $__TGZ
		tar -zxvf $__TGZ > /dev/null 2>&1
	done
	popd > /dev/null 2>&1
}

# $1 -> check_tgz_like_original_folder_with_exclusions
# rest -> tgz 
function check_tgz_exact_as_original_folder(){
	local __FOLDER="$1"
	local __TMP=$(mktemp -d)
	local __TGZ
	shift	
	untar_tgzs $__TMP $*
	check_contents_folder_equals "$__FOLDER" "$__TMP"
	assertEquals "Tgz and folder are equals" $? 0 
	rm -Rf $__TMP
	
}

# $1 -> original folder
# $2 -> tgz
# $3...n -> exclusions patterns for diff
function check_tgz_like_original_folder_with_exclusions(){
	local __FOLDER="$1"
	local __TMP=$(mktemp -d)
	local __TGZ="$2"
	shift 2
	untar_tgzs $__TMP $__TGZ
	check_contents_folder_equals "$__FOLDER" "$__TMP" $*
	assertEquals "Tgz and folder are equals" $? 0 
	rm -Rf $__TMP
}

###############################################################################
# TEST
###############################################################################
DISABLED_test_fails_params() {
	$SNAPSHOT -k  
	assertEquals $? 1
}



test_first_backup() {
	
	local _RESULT_FILE=$__TMP_FOLDER_TO_STORE_BACK/result.txt
	VERBOSE using folder "[$__TMP_FOLDER_TO_STORE_BACK]"
	$SNAPSHOT -s $__TMP_DATA_TO_BACK -d $__TMP_FOLDER_TO_STORE_BACK -r $_RESULT_FILE 
	assertEquals "jbackup returns error" $? 0

	. $_RESULT_FILE 
	VERBOSE "generated tgz: $DELTA_BACKUP_RESULT"
	check_tgz_exact_as_original_folder  "$__TMP_DATA_TO_BACK" "$DELTA_BACKUP_RESULT"
	
}

test_two_backups_with_modifications() {
	LOG "Testing that modified files are stored on delta backup"
	local _RESULT_FILE=$__TMP_FOLDER_TO_STORE_BACK/result.txt
	local __TGZS=""

	$SNAPSHOT -s $__TMP_DATA_TO_BACK -d $__TMP_FOLDER_TO_STORE_BACK -r $_RESULT_FILE 
	assertEquals "jbackup returns error" $? 0
	. $_RESULT_FILE 
	__TGZS=$DELTA_BACKUP_RESULT
	VERBOSE "generated tgz: $DELTA_BACKUP_RESULT"

	VERBOSE "Changing a file"
	echo "another line" >> $__TMP_DATA_TO_BACK/readme.txt

	VERBOSE "Generating day 2"
	$SNAPSHOT -s $__TMP_DATA_TO_BACK -d $__TMP_FOLDER_TO_STORE_BACK -r $_RESULT_FILE 
	assertEquals "jbackup returns error" $? 0
	. $_RESULT_FILE 
	__TGZS="$__TGZS $DELTA_BACKUP_RESULT"

	VERBOSE "generated tgzs: $__TGZS"
	check_tgz_exact_as_original_folder  "$__TMP_DATA_TO_BACK" $__TGZS
	
}

test_backup_with_pattern_filename_that_implies_create_folder() {
	local _RESULT_FILE=$__TMP_FOLDER_TO_STORE_BACK/result.txt
	$SNAPSHOT -s $__TMP_DATA_TO_BACK -d $__TMP_FOLDER_TO_STORE_BACK -r $_RESULT_FILE  -f "FOLDER/%Y%m%d-%s"
	assertEquals "jbackup returns error" $? 0
	local __EXPECTED_FOLDER="${__TMP_FOLDER_TO_STORE_BACK}/FOLDER"
	assertTrue "subfolder $__EXPECTED_FOLDER must be created"  "[ -d $__EXPECTED_FOLDER ]"
}

test_exclude_pattern(){
	local _RESULT_FILE=$__TMP_FOLDER_TO_STORE_BACK/result.txt
	$SNAPSHOT -s $__TMP_DATA_TO_BACK -d $__TMP_FOLDER_TO_STORE_BACK -r $_RESULT_FILE  -X "*.txt"
	assertEquals "jbackup returns error" $? 0
	. $_RESULT_FILE 
	check_tgz_like_original_folder_with_exclusions  "$__TMP_DATA_TO_BACK" "$DELTA_BACKUP_RESULT" --exclude "*.txt"
}

set_logger_level $LOG_LEVEL_WARNING_CTE
source $SHUNIT2
