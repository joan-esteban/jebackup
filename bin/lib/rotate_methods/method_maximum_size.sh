#!/bin/bash
source $(dirname $0)/lib/rotate_methods/common.sh
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
#ROTATE_MAXIMUM_SIZE_TARGET_MB

#
# This is the main method
# $1 -> where are backups
# return:
# 		FILES_TO_DELETE
function get_files_to_remove(){
	local __DEST=$1
	ASSERT "[ ! -z $ROTATE_MAXIMUM_SIZE_TARGET_MB ]" "Var ROTATE_MAXIMUM_SIZE_TARGET_MB must be set"
	get_folder_size_mb "$__DEST"
	ASSERT "[ ! -z $FOLDER_SIZE_MB ]" "Must return FOLDER_SIZE_MB"
	if [ $FOLDER_SIZE_MB -gt $ROTATE_MAXIMUM_SIZE_TARGET_MB ]; then
		LOG "something to do,  $FOLDER_SIZE_MB \> $ROTATE_MAXIMUM_SIZE_TARGET_MB"
	fi
	
}