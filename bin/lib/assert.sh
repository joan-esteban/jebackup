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


###############################################################################
# PUBLIC
###############################################################################

# Check a condition,if fails show an error and finish program
# $1 -> condition (must be between ")
# $2 -> Text to show on fails
# Example:
# 	ASSERT "[ ! -z $SOURCE_FOLDER ]" "you must set source folder!"
function ASSERT(){
	eval $1
	if [ $? -ne 0 ]; then
		shift		
		ERROR $*
		exit 1
	fi
}
