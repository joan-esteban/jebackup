#!/bin/bash

###############################################################################
# PUBLIC
###############################################################################
LOG_LEVEL_SILENT_CTE=0
LOG_LEVEL_ERROR_CTE=1
LOG_LEVEL_WARNING_CTE=2
LOG_LEVEL_LOG_CTE=3
LOG_LEVEL_VERBOSE_CTE=4



# Set  which logs will be show 
# example: 
#   -Max verbosity:
#    	set_logger_level $LOG_LEVEL_VERBOSE_CTE 
#  
#   - No output:
#	set_logger_level $LOG_LEVEL_SILENT_CTE

function set_logger_level(){
	LOG_LEVEL=$1
}

function ERROR(){
	__internal_log_handle $LOG_LEVEL_ERROR_CTE $LOGGER_ERROR_COLOR "[ERROR] " $*
	false
}

function WARNING(){
	__internal_log_handle $LOG_LEVEL_WARNING_CTE $LOGGER_WARNING_COLOR "[WARN ] " $*
}

function LOG(){
	__internal_log_handle $LOG_LEVEL_LOG_CTE $LOGGER_LOG_COLOR "[LOG  ] " $*
}


function VERBOSE(){
	__internal_log_handle $LOG_LEVEL_VERBOSE_CTE $LOGGER_VERBOSE_COLOR "[VRB  ] " $*
}

# Filter output as $1
# example:
# 	ls -la | FILTER_AS $LOG_LEVEL_LOG_CTE
function LOG_OUTPUT_FILTER_AS(){
	while read LINE; do
		__internal_log_handle $1 $LOGGER_VERBOSE_COLOR "[OUT  ] " $LINE
	done
}

function LOG_OUTPUT_FILTER(){
	LOG_OUTPUT_FILTER_AS $LOG_LEVEL_LOG_CTE
}


###############################################################################
# PRIVATE STUFF
###############################################################################

__LOG_LEVEL=${LOG_LEVEL_VERBOSE_CTE}

function __internal_log_handle(){
	local LEVEL="$1"
	local COLOR="$2"
	local PREFIX="$3"
	shift 3
	if [ $LOG_LEVEL -ge $LEVEL ] ; then
		echo -e ${COLOR}"${PREFIX}"$*${END_ANSI} >&2
	fi
}



