#!/bin/bash
source $(dirname $0)/lib/ansicolors.sh
source $(dirname $0)/lib/logger.sh
source $(dirname $0)/lib/assert.sh

function show_help(){
	echo "$0 -s <source_folder> -d <dest_folder> -v"
	echo " "
	echo " -c <config file>     : file with params"
	echo " -s <source_folder>   : folder that you want to backup (SOURCE_FOLDER)"
	echo " -d <dest_folder>     : where backup are stored (DEST_FOLDER)"
	echo " -r <result file>     : store result info at this file (RESULT_FILE)"
	echo " -X <exclude patterns>: list of patterns using pipe as field separator (EXCLUDE_PATTERNS_FROM_BACKUP)"
	echo " -f <pattern bck file>: pattern for filename ex:$GENERATED_BACKUP_FILE_PATTERN (GENERATED_BACKUP_FILE_PATTERN)"		
	echo " -v                   : verbosity"
	echo " -u                   : dry-run"
	echo " -h                   : show help"
}

function get_args_params(){
	local OPT
	OPTERR=0
	while getopts ":s:d:vhr:c:f:X:" OPT; do
		case $OPT in
			s)
				SOURCE_FOLDER="${OPTARG}"
				;;
			d)
				DEST_FOLDER="${OPTARG}"
				;;
			c)
				CONFIG_FILE="${OPTARG}"
				;;
			X)
				EXCLUDE_PATTERNS_FROM_BACKUP="${OPTARG}"
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
			h)	
				show_help
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

function output_result(){
	echo "DELTA_BACKUP_RESULT=$DELTA_BACKUP_RESULT" 
}

function output_parameters_used(){
	echo "SOURCE_FOLDER=$SOURCE_FOLDER"
	echo "DEST_FOLDER=$DEST_FOLDER"
	echo "EXCLUDE_PATTERNS_FROM_BACKUP=$EXCLUDE_PATTERNS_FROM_BACKUP"
	echo "RESULT_FILE=$RESULT_FILE"
	echo "GENERATED_BACKUP_FILE_PATTERN=$GENERATED_BACKUP_FILE_PATTERN"
}

function set_defaults_values(){
	GENERATED_BACKUP_FILE_PATTERN="%Y%m%d-%s"
	EXCLUDE_PATTERNS_FROM_BACKUP='core|*.swp|*~'
}

###############################################################################
# MAIN
###############################################################################

# Setting default log level
set_logger_level $LOG_LEVEL_WARNING_CTE
set_defaults_values 
get_args_params $*
ASSERT "[ $? -eq 0 ]" "Error parsing arguments"

if [ ! -z $CONFIG_FILE ]; then
	VERBOSE "reading config file $CONFIG_FILE (this file overwrite commandline parameters)"
	ASSERT "[ -f $CONFIG_FILE ]" "Doesnt exists any file called $CONFIG_FILE"
	source "$CONFIG_FILE"
fi

ASSERT "[ ! -z $SOURCE_FOLDER ]" "you must set source folder!"
ASSERT "[ ! -z $DEST_FOLDER ]" "you must set destination folder!"

# TODO : In the future the engine could be changed
source $(dirname $0)/lib/tgzengine.sh

create_delta_backup "$SOURCE_FOLDER" "$DEST_FOLDER"

if [ ! -z $RESULT_FILE ] ; then
	output_result > $RESULT_FILE 
else
	output_result
fi


