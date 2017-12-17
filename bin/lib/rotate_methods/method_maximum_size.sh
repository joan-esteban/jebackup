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
ASSERT_EXISTS_FUNCTION get_list_of_backup_files "you must import rotate_methods/common.sh before use $0"
ASSERT_EXISTS_FUNCTION set_result_original_size_backup_mb "you must import rotate_methods/common.sh before use $0"
ASSERT_EXISTS_FUNCTION can_remove_filename "you must import rotate_methods/common.sh before use $0"
ASSERT_EXISTS_FUNCTION add_result_remove_file "you must import rotate_methods/common.sh before use $0"
ASSERT_EXISTS_FUNCTION set_result_goal_achieve "you must import rotate_methods/common.sh before use $0"
###############################################################################
# PUBLIC
###############################################################################

#
# This is the main method
# $1 -> where are backups
# return:
# 		FILES_TO_DELETE
function get_files_to_remove(){
	local __DEST=$1
	local __TMPFILE_SET_BACKUP_FILES=$(mktemp)
	ASSERT "[ ! -z $ROTATE_MAXIMUM_SIZE_TARGET_MB ]" "Var ROTATE_MAXIMUM_SIZE_TARGET_MB must be set"
	ASSERT "[ ! -z $PATTERN_BACKUP_FILES ]" "Var PATTERN_BACKUP_FILES must be set"
	
	get_list_of_backup_files "$__DEST" "$__TMPFILE_SET_BACKUP_FILES"
	
	__how_much_need_to_reduce "$__TMPFILE_SET_BACKUP_FILES" $ROTATE_MAXIMUM_SIZE_TARGET_MB
	if [ $REDUCE_MB -gt 0 ]; then
		# I have to do something
		__decice_which_files_to_remove "$__TMPFILE_SET_BACKUP_FILES" $REDUCE_MB
	fi
	rm $__TMPFILE_SET_BACKUP_FILES
}

###############################################################################
# PRIVATE STUFF
###############################################################################

# $1 -> where are backup
# returns 
#   variable REDUCE_MB
function __how_much_need_to_reduce(){
	local __DEST="$1"
	local __TARGET_MB=$2
	REDUCE_MB=0
	
	get_list_of_backup_files_size_mb "$__DEST"
	ASSERT "[ ! -z $BACKUP_FILES_SIZE_MB ]" "Must return BACKUP_FILES_SIZE_MB"
	LOG "Backup  size [$BACKUP_FILES_SIZE_MB Mb]"
	set_result_original_size_backup_mb $BACKUP_FILES_SIZE_MB 
	if [ $BACKUP_FILES_SIZE_MB -gt $__TARGET_MB ]; then
		REDUCE_MB=$(($BACKUP_FILES_SIZE_MB - $__TARGET_MB))
		LOG "something to do,  $BACKUP_FILES_SIZE_MB Mb > $__TARGET_MB Mb, need to free up ${REDUCE_MB} Mb"
	fi
}


function __decice_which_files_to_remove(){
	local __TMPFILE="$1"
	local __REDUCE_MB=$2
	local __PENDING_BYTES=$(echo $__REDUCE_MB \* $BYTES_IN_MB_CTE | bc)
	local __REDUCED_BYTES=0
	local __LAST_MOD
	local __SIZE_BYTES
	local __FILENAME
	local __OLD_IFS="$IFS"
	IFS="|"
	while read __LAST_MOD __SIZE_BYTES __FILENAME; do
		if [ $(echo $__PENDING_BYTES \> 0 | bc) == "1" ]; then
			can_remove_filename "$__FILENAME"
			if [ $? -eq 0 ]; then
				add_result_remove_file "$__FILENAME" "Pending bytes to remove [$__PENDING_BYTES bytes]"
				VERBOSE  "mark to delete [$__FILENAME] because pending bytes [$__PENDING_BYTES]"
				__PENDING_BYTES=$(echo $__PENDING_BYTES - $__SIZE_BYTES | bc)
				__REDUCED_BYTES=$(echo $__REDUCED_BYTES + $__SIZE_BYTES | bc)
				set_result_total_size_reduced_mb $(echo $__REDUCED_BYTES /  $BYTES_IN_MB_CTE | bc)
				if [ $(echo $__PENDING_BYTES \> 0 | bc) == "0" ] ; then
					VERBOSE "Goal achieve! no more files to delete"
					set_result_goal_achieve
				fi
			fi
		fi
		
	done < $__TMPFILE
	IFS="$__OLD_IFS"	
}