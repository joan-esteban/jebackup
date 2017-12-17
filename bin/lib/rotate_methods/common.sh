#!/bin/bash
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
# NO_REMOVE_FILES_NEWER_THRESHOLD_SECONDS: Don't delete files that recently created
NO_REMOVE_FILES_NEWER_THRESHOLD_SECONDS=10
#PATTERN_BACKUP_FILES
# Example: ^backup-*.tgz$
PATTERN_BACKUP_FILES='*.tgz'
RECURSIVE_BACKUP_FILES=1


BYTES_IN_MB_CTE=1048576

#--- result ----------------------
# RESULT_ROTATE_REMOVE_FILES file with list of files
# RESULT_ROTATE_ORIGINAL_SIZE_BACKUP_MB
# RESULT_ROTATE_FINAL_SIZE_BACKUP_MB

RESULT_ROTATE_REMOVE_FILES=""
RESULT_ROTATE_GOAL_ACHIEVE=0
# $1 -> size
function set_result_original_size_backup_mb(){
	LOG "Backup size[$1 Mb]"
	RESULT_ROTATE_ORIGINAL_SIZE_BACKUP_MB="$1"
}

function set_result_total_size_reduced_mb(){
	RESULT_ROTATE_REDUCED_SIZE_BACKUP_MB="$1"
}

function set_result_goal_achieve(){
	RESULT_ROTATE_GOAL_ACHIEVE=1
}

# $1 -> filename
# $2 -> reason
function add_result_remove_file(){
	if [ -z $RESULT_ROTATE_REMOVE_FILES ]; then	
		if [ ! -z $RESULT_FILE ]; then
			RESULT_ROTATE_REMOVE_FILES="${RESULT_FILE}.rotate_files"
			# Clean old results
			rm "$RESULT_ROTATE_REMOVE_FILES"
		else
			RESULT_ROTATE_REMOVE_FILES=$(mktemp)
		fi
	fi
	LOG "Add file [$1] beacause [$2]"
	echo "$1|$2" >> $RESULT_ROTATE_REMOVE_FILES
}


function output_result_rotate(){
	echo RESULT_ROTATE_ORIGINAL_SIZE_BACKUP_MB=$RESULT_ROTATE_ORIGINAL_SIZE_BACKUP_MB
	echo RESULT_ROTATE_REDUCED_SIZE_BACKUP_MB=$RESULT_ROTATE_REDUCED_SIZE_BACKUP_MB
	echo RESULT_ROTATE_REMOVE_FILES=$RESULT_ROTATE_REMOVE_FILES
	echo RESULT_ROTATE_GOAL_ACHIEVE=$RESULT_ROTATE_GOAL_ACHIEVE
	if [ ! -z $RESULT_ROTATE_REMOVE_FILES ]; then
		cat $RESULT_ROTATE_REMOVE_FILES | xargs -l echo "#"
	fi
}



###############################################################################
# PROTECTED
###############################################################################

# $1 -> file with list of files 
# return BACKUP_FILES_SIZE_MB
function get_list_of_backup_files_size_mb(){
	local __TMPFILE="$1"
	local __OLD_IFS="$IFS"
	local __BYTES=0
	IFS="|"
	while read __LAST_MOD __SIZE_BYTES __FILENAME; do
		__BYTES=$(echo $__BYTES + $__SIZE_BYTES | bc)		
	done < $__TMPFILE
	IFS="$__OLD_IFS"
	BACKUP_FILES_SIZE_MB=$(echo "$__BYTES / $BYTES_IN_MB_CTE" | bc)
}

# $1 -> path backups
# returns FOLDER_SIZE_MB
function get_folder_size_mb(){
	local __DEST=$1
	FOLDER_SIZE_MB=$(du -s -m "$__DEST" | cut -f 1)
	VERBOSE "size for folder [$__DEST] are [$FOLDER_SIZE_MB mb]"
}

# $1->FOLDER
# $2->RESULT FILE
# result:
# 	file with all backup files with <tstamp mod>|<size in bytes>|<full filename>
function get_list_of_backup_files(){
	local __DEST="$1"
	local __TMPFILE="$2"
	local __EXTRA_CMD=""
	if [ $RECURSIVE_BACKUP_FILES -eq 0 ]; then
		__EXTRA_CMD="-maxdepth 1"
	fi
	# %Y tstamp last mod
	# %s size in bytes
	# %n filename
	find "$__DEST" $__EXTRA_CMD -type f -iname "${PATTERN_BACKUP_FILES}" -exec stat --format "%Y|%s|%n" "{}" \; | sort -n > $__TMPFILE
	cat $__TMPFILE | LOG_OUTPUT_FILTER
	true
}

function add_file_to_delete(){
	true
}

# $1 -> filename
function can_remove_filename(){
	local __FILE=$1
	if [ ! -z $NO_REMOVE_FILES_NEWER_THRESHOLD_SECONDS ]; then
		local __MOD_TSTAMP=$(stat --format "%Y" "$__FILE")
		local __NOW_TSTAMP=$(date +%s)
		if [ $(echo "($__NOW_TSTAMP - $__MOD_TSTAMP ) < $NO_REMOVE_FILES_NEWER_THRESHOLD_SECONDS" | bc) == "1" ]; then
			WARNING "Cant delete file [$__FILE] beacause has been created too recently $__NOW_TSTAMP - $__MOD_TSTAMP < $NO_REMOVE_FILES_NEWER_THRESHOLD_SECONDS "
			false
			return
		fi
	fi
	true
	return 
}



