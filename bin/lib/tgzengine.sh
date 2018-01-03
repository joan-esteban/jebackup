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
# $1 -> dest_folder (where must be control files)
# $2 -> source_folder
# return:
# 	DELTA_BACKUP_RESULT= filename created with full path
function create_delta_backup(){
	local DEST=$1
	shift
	local __NUM_SOURCES=$#
	local __SOURCE=""
	local __TAR_TARGET_CMD=""
	local __TAR_TARGET_FOLDERS=""

	ASSERT "[ $__NUM_SOURCES -gt 0 ]" "minimum 1 source folder to backup"
	# Get DEST info
	ASSERT "[ -d $DEST ]" destination folder [$DEST] must exists
	__get_backup_filenames $DEST
	ASSERT "[ ! -z $__BACKUP_DEST_FILENAME ]" "__get_backup_filenames must return __BACKUP_DEST_FILENAME"
	ASSERT "[ ! -e $__BACKUP_DEST_FILENAME ]" "__get_backup_filenames returns [$__BACKUP_DEST_FILENAME] that exists, I'm not going to overwrite!"
	ASSERT "[ ! -z $__BACKUP_INCREMENTAL_FILE ]" "__get_backup_filenames must return someting"
	__get_excludes_cmdline $DEST
	ASSERT "[ ! -z \"$_EXCLUDES_CMD\" ]" "__get_excludes_cmdline must return _EXCLUDES_CMD"
	# Get SOURCE info
	while [ ! -z "$1" ]; do
		__SOURCE="$1"
		ASSERT "[ -d $__SOURCE ]" source folder [$__SOURCE] must exists
		__TAR_TARGET_FOLDERS="$__TAR_TARGET_FOLDERS $__SOURCE"
		shift
		
	done
	

	
	# NOTE:  -C $SOURCE if for extracting prefix from files
	# ex: taring /var/log -> without C it keep /var/log for each file
	#TAR_CMD="tar -zcv --same-permissions   --seek --ignore-failed-read --same-owner  $_EXCLUDES_CMD --listed-incremental $__BACKUP_INCREMENTAL_FILE -f $__BACKUP_DEST_FILENAME -C $__SOURCE ."
	if [ $__NUM_SOURCES -gt 1 ]; then
		TAR_CMD="tar -zcv --same-permissions   --seek --ignore-failed-read --same-owner  $_EXCLUDES_CMD --listed-incremental $__BACKUP_INCREMENTAL_FILE -f $__BACKUP_DEST_FILENAME  $__TAR_TARGET_FOLDERS"
	else # Just 1 source
		# If is 1 SOURCE it extract prefix form files
		TAR_CMD="tar -zcv --same-permissions   --seek --ignore-failed-read --same-owner  $_EXCLUDES_CMD --listed-incremental $__BACKUP_INCREMENTAL_FILE -f $__BACKUP_DEST_FILENAME  -C $__TAR_TARGET_FOLDERS ."
	fi
	VERBOSE executing $TAR_CMD
	$TAR_CMD 2>&1 | LOG_OUTPUT_FILTER  
	local __RESULT=${PIPESTATUS[0]}
	VERBOSE "tgz return code: $__RESULT"
	DELTA_BACKUP_RESULT=$__BACKUP_DEST_FILENAME
	return $__RESULT
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
		_EXCLUDES_CMD=" "
		IFS="|"
		for __PATTERN in $EXCLUDE_PATTERNS_FROM_BACKUP; do
			_EXCLUDES_CMD="$_EXCLUDES_CMD --exclude $__PATTERN "
		done
		IFS="$__OLD_IFS"
	else
		_EXCLUDES_CMD="--exclude core --exclude *.swp --exclude *~"	
	fi
	VERBOSE "Exclusion command line: $_EXCLUDES_CMD"
}

