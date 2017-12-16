#!/bin/bash
source $(dirname $0)/lib/outputfile.sh
###############################################################################
# PRECONDITIONS
###############################################################################

# $1-> function
# $*-> error message
function ASSERT_EXISTS_FUNCTION(){
	if [ -z $(type -t f $1) ] ; then
		echo $* >&2
		exit 1
	fi
}
ASSERT_EXISTS_FUNCTION ERROR "you must import logger.sh before use $0"
ASSERT_EXISTS_FUNCTION ASSERT "you must import assert.sh before use $0"

###############################################################################
# PUBLIC
###############################################################################


# this function create a delta
# $1 -> source_folder
# $2 -> dest_folder (where must be control files)
# return:
# 	DELTA_BACKUP_RESULT= filename created with full path
function create_delta_backup(){
	local SOURCE=$1
	local DEST=$2
	ASSERT "[ -d $SOURCE ]" source folder [$SOURCE] must exists
	ASSERT "[ -d $DEST ]" destination folder [$DEST] must exists
	__get_backup_filenames $DEST
	ASSERT "[ ! -z $__BACKUP_DEST_FILENAME ]" "get_backup_dest_filename must return someting"
	ASSERT "[ ! -e $__BACKUP_DEST_FILENAME ]" "get_backup_dest_filename returns [$__BACKUP_DEST_FILENAME] that exists, I'm not going to overwrite!"
	ASSERT "[ ! -z $__BACKUP_INCREMENTAL_FILE ]" "get_backup_dest_filename must return someting"

	__get_excludes_cmdline $DEST
	# NOTE:  -C $SOURCE if for extracting prefix from files
	# ex: taring /var/log -> without C it keep /var/log for each file
	TAR_CMD="tar -zcv --same-permissions   --seek --ignore-failed-read --same-owner  $__EXCLUDES_CMD --listed-incremental $__BACKUP_INCREMENTAL_FILE -f $__BACKUP_DEST_FILENAME -C $SOURCE ."
	VERBOSE executing $TAR_CMD
	$TAR_CMD 2>&1 | LOG_OUTPUT_FILTER  
	DELTA_BACKUP_RESULT=$__BACKUP_DEST_FILENAME
}

###############################################################################
# PRIVATE STUFF
###############################################################################

# This function generate a name for file to create
# $1 -> destination folder
# return:
# 	__BACKUP_DEST_FILENAME=
function __get_backup_filenames(){
	get_backup_prefix_filename_and_create_folder_if_needed "$1"
	ASSERT "[ ! -z $BACKUP_DEST_FULLPATH_FILENAME_PREFIX ]" "get_backup_prefix_filename_and_create_folder_if_needed must set BACKUP_DEST_FULLPATH_FILENAME_PREFIX"

	
		
	local __TSTAMP="$(date +%Y%m%d-%s)"
	ASSERT "[ ! -z $1 ]" __get_backup_dest_filename need destionation_folder param
	
	__BACKUP_DEST_FILENAME=${BACKUP_DEST_FULLPATH_FILENAME_PREFIX}.tgz
	__BACKUP_INCREMENTAL_FILE=$(dirname ${BACKUP_DEST_FULLPATH_FILENAME_PREFIX})/master.incremental
	local __TRY=1
	while [ -e "$__BACKUP_DEST_FILENAME" ]; do
		__BACKUP_DEST_FILENAME=${BACKUP_DEST_FULLPATH_FILENAME_PREFIX}-$(printf %02d $__TRY).tgz
		__TRY=$(expr $__TRY + 1)
	done
}


# global EXCLUDE_PATTERNS_FROM_BACKUP
function __get_excludes_cmdline(){
	if [ ! -z $EXCLUDE_PATTERNS_FROM_BACKUP ]; then
		local __OLD_IFS="$IFS"
		local __PATTERN
		__EXCLUDES_CMD=""
		IFS="|"
		for __PATTERN in $EXCLUDE_PATTERNS_FROM_BACKUP; do
			__EXCLUDES_CMD="$__EXCLUDES_CMD --exclude $__PATTERN "
		done
		IFS="$__OLD_IFS"
	else
		__EXCLUDES_CMD="--exclude core --exclude *.swp --exclude *~"	
	fi
	VERBOSE "Exclusion command line: $__EXCLUDES_CMD"
}

