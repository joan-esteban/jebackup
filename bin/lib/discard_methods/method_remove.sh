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

#
# This is the main method
# $1 -> where are backups
# $2 -> file with files to discard
# implicit: RESULT_ROTATE_REMOVE_FILES (filled by prior stage)
# return:
# 		FILES_TO_DELETE
function discard_files_marked_to_remove(){
	local __DEST="$1"
	local __MARK_TO_DISCARD_FILE="$2"
	if [ -z $__MARK_TO_DISCARD_FILE ]; then
		VERBOSE "Nothing to do"
		return
	fi
	
	local __OLD_IFS="$IFS"
	local __FILENAME
	local __REASON
	IFS="|"
	while read  __FILENAME __REASON; do
		VERBOSE "Removing file [$__FILENAME]"
		if [  -z $DRY_RUN ]; then
			# Real delete
			VERBOSE "Removing file [$__FILENAME]"
			rm -f "$__FILENAME"
		else
			VERBOSE "Removing file [$__FILENAME] : dry run! so nothing to do"
		fi
	done < $__MARK_TO_DISCARD_FILE
	IFS="$__OLD_IFS"
	
	
	
	
	
}
