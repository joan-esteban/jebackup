#!/bin/bash
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

# $1 -> path backups
# returns BACKUP_SIZE_KB
function get_folder_size_kb(){
	local __DEST=$1
	BACKUP_FOLDER_KB=$(du -s -k "$__DEST" | cut -f 1 -d ' ')
}

function get_folder_size_mb(){
	local __DEST=$1
	FOLDER_SIZE_MB=$(du -s -m "$__DEST" | cut -f 1 -d ' ')
	VERBOSE "size for folder [$__DEST] are [$FOLDER_SIZE_MB mb]"
}

function get_olders_backup_to_reduce(){
	true
}

function get_olders_backup_since(){
	true
}



