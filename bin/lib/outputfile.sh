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

# $1-> destination folder base
# returns:
# 	BACKUP_DEST_FULLPATH_FILENAME_PREFIX
function get_backup_prefix_filename_and_create_folder_if_needed(){
	local __DEST_FOLDER="$1"
	ASSERT "[ -d $__DEST_FOLDER ]" "Cant get backup filename for a inexistent folder [$__DEST_FOLDER]"
	local __PREFIX_NAME="$(date +${GENERATED_BACKUP_FILE_PATTERN})"
	__check_dirname_for_prefix_filename_and_create_folder "$__DEST_FOLDER" "$__PREFIX_NAME"
	BACKUP_DEST_FULLPATH_FILENAME_PREFIX="${__DEST_FOLDER}/${__PREFIX_NAME}"
}

###############################################################################
# PRIVATE STUFF
###############################################################################



function __check_dirname_for_prefix_filename_and_create_folder(){
	local __DEST_FOLDER="$1"
	local __PREFIX_NAME="$2"
	local __DIRNAME=$(dirname $__PREFIX_NAME)
	if [ "$__DIRNAME" != "." ]; then
		# In pattern there are a folder
		__DEST_FOLDER="$__DEST_FOLDER/$__DIRNAME"
		if [ ! -d "$__DEST_FOLDER" ] ; then
			# I'm going to create it
			mkdir -p "$__DEST_FOLDER"
		fi
	fi
}
