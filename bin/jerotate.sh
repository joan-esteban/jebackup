#!/bin/bash
###############################################################################
# JEROTATE
# -----------------------------------------------------------------------------
# This file keep backup at desired size
###############################################################################

source $(dirname $0)/lib/ansicolors.sh
source $(dirname $0)/lib/logger.sh
source $(dirname $0)/lib/assert.sh
source $(dirname $0)/lib/methods.sh
source $(dirname $0)/lib/rotate_methods/common.sh
source $(dirname $0)/lib/discard_methods/common.sh

function show_help(){
	echo "$0 -d <dest_folder> -m <method> -a <discard_method>  -s <VAR=VALUE> -v -u -h"
	echo " "
	echo " -c <config file>     : file with params"
	echo " -r <result file>     : store result info at this file (RESULT_FILE)"
	echo " -d <dest_folder>     : where backup are stored (DEST_FOLDER)"
	echo " -m <method>          : how do you want to control size? (METHOD_ROTATE)"
	show_methods_for METHOD_ROTATE_AVAILABLE
	#echo "                          maximum_size : it keep under maximum size"
	#echo "                          outdated : it keep a fixed number of days"
	#echo "                          percent_free : it try to mantain a % of free storage on backup unit"
	echo " -a <discard_method>  : what to do to discards backups?"
	show_methods_for METHOD_DISCARD_AVAILABLE
	#echo "                          delete : discard backup are deleted"
	#echo "                          move : discard backup are moved to another place"	
	#echo "                          none : look away and whistle"	
	echo " -s <VAR=VALUE>       : Set especific value Ex: ROTATE_MAXIMUM_SIZE_TARGET_MB=4"
	echo " -v                   : verbosity"
	echo " -u                   : dry run"
	echo " -h                   : show help"
}

function get_args_params(){
	local OPT
	OPTERR=0
	while getopts ":s:d:vhr:c:f:X:m:a:u" OPT; do
		case $OPT in
			d)
				DEST_FOLDER="${OPTARG}"
				;;
			c)
				CONFIG_FILE="${OPTARG}"
				;;
			m)
				METHOD_ROTATE="${OPTARG}"
				;;
			a)
				METHOD_DISCARD="${OPTARG}"
				;;
			f)
				GENERATED_BACKUP_FILE_PATTERN="${OPTARG}"
				;;
			v)
				set_logger_level $LOG_LEVEL_VERBOSE_CTE
				VERBOSE "Activate verbose"
				show_what_are_logger_showing
				;;
			r)
				RESULT_FILE="${OPTARG}"
				;;
			s)
				set_variable "${OPTARG}"
				;;
				
			u)
				DRY_RUN=1
				;;
			h)	
				show_help
				exit 0
				;;
			:)
				ERROR "param -$OPTARG required a parameter, check help with $0 -h"
				;;
			*)
				ERROR "unknown param -$OPTARG , check help with $0 -h"
				;;
		esac
	done
}

function show_what_are_logger_showing(){
	LOG "log level traces are showing"
	ERROR "error level traces are showing"
	WARNING "warning level traces are showing"
	VERBOSE "verbose level traces are showing"

}

function set_defaults_values(){
	GENERATED_BACKUP_FILE_PATTERN="%Y%m%d-%s"
	EXCLUDE_PATTERNS_FROM_BACKUP='core|*.swp|*~'
	METHOD_DISCARD=none
	METHOD_ROTATE=none
}



###############################################################################
# MAIN
###############################################################################
set_logger_level $LOG_LEVEL_WARNING_CTE
set_logger_level $LOG_LEVEL_VERBOSE_CTE
set_defaults_values 
get_available_method METHOD_ROTATE_AVAILABLE $(dirname $0)/lib/rotate_methods/method_*.sh
get_available_method METHOD_DISCARD_AVAILABLE $(dirname $0)/lib/discard_methods/method_*.sh
get_args_params $*
ASSERT "[ $? -eq 0 ]" "Error parsing arguments"

if [ ! -z $CONFIG_FILE ]; then
	VERBOSE "reading config file $CONFIG_FILE (this file overwrite commandline parameters)"
	ASSERT "[ -f $CONFIG_FILE ]" "Doesnt exists any file called $CONFIG_FILE"
	source "$CONFIG_FILE"
fi

ASSERT "[ ! -z $DEST_FOLDER ]" "you must set backup folder!"

__METHOD_ROTATE_SOURCE_CODE=$(dirname $0)/lib/rotate_methods/method_${METHOD_ROTATE}.sh
ASSERT "[ -f $__METHOD_SOURCE_CODE ]" "Method $METHOD_ROTATE doesnt have support, (missing file $__METHOD_ROTATE_SOURCE_CODE)"
source $__METHOD_ROTATE_SOURCE_CODE

__METHOD_DISCARD_SOURCE_CODE=$(dirname $0)/lib/discard_methods/method_${METHOD_DISCARD}.sh
ASSERT "[ -f $__METHOD_DISCARD_SOURCE_CODE ]" "Method $METHOD_DISCARD doesnt have support, (missing file $__METHOD_DISCARD_SOURCE_CODE)"
source $__METHOD_DISCARD_SOURCE_CODE

get_files_to_remove "$DEST_FOLDER"
VERBOSE "Rotate finish working, calling discard"

discard_files_marked_to_remove "$DEST_FOLDER" "$RESULT_ROTATE_REMOVE_FILES"
VERBOSE "Discard finish working"

if [ ! -z $RESULT_FILE ] ; then
	output_result_rotate > $RESULT_FILE 
	output_result_discard >> $RESULT_FILE
else
	output_result_rotate
	output_result_discard
fi
