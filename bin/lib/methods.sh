#!/bin/bash
###############################################################################
# PRECONDITIONS
###############################################################################

# $1-> function
# $*-> error message
unset  ASSERT_EXISTS_FUNCTION
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
# $1 prefix var
function show_methods_for(){
	local __NAME_VAR="$1"
	local __METHOD_LIST
	local __METHOD
	eval "__METHOD_LIST=\$$__NAME_VAR"
	for __METHOD in $__METHOD_LIST; do
		local __METHOD_DESC
		eval "__METHOD_DESC=\$${__NAME_VAR}_${__METHOD}_DESC"
		echo "                          $__METHOD : $__METHOD_DESC"
	done
}

#
# $1 prefix var where keep it
# $* files for methods
function get_available_method(){
	local __NAME_VAR="$1"
	local __NAME_VAR_DESCRIPTION="$1"
	local __METHOD
	local __NAME
	local __ACC_NAME=""
	shift
	for __METHOD in $* ; do
		__NAME=$(echo $__METHOD | grep -Po 'method_\K[^.]*')
		__ACC_NAME="$__ACC_NAME $__NAME"
		# This create METHOD_ROTATE_AVAILABLE_maximum_size_DESC
		local __FILENAME_PARAMS=$(echo $__METHOD | sed 's/.sh$/.desc/g')
		__expand_var_in_file $__FILENAME_PARAMS ${__NAME_VAR}_${__NAME}_
		#eval ${__NAME_VAR}_${__NAME}_DESC="hola"
	done
	VERBOSE "find next methods: [$__ACC_NAME]" 
	eval $__NAME_VAR=\"$__ACC_NAME\"
}

# $1-> text "VAR=KEY"
function set_variable(){
	local __LINE="$1"
	local __KEY=$(echo $__LINE | cut -f 1 -d '=')
	local __VALUE=$(echo $__LINE | cut -f 2- -d '=')
	VERBOSE "setting ${__KEY}=$__VALUE "
	eval ${__KEY}=\"$__VALUE\"
}

###############################################################################
# PRIVATE STUFF
###############################################################################

# $1 - filename
# $2 - prefix var
function __expand_var_in_file(){
	local __FILE=$1
	local __PREFIX_VAR=$2
	local __OLD_IFS="$IFS"
	local __LINE
	if [ -f $__FILE ]; then
		IFS=$'\n'
		while read __LINE ; do	
			local __KEY=$(echo $__LINE | cut -f 1 -d '=')
			local __VALUE=$(echo $__LINE | cut -f 2- -d '=')
			VERBOSE "setting ${__PREFIX_VAR}${__KEY}=$__VALUE "
			eval ${__PREFIX_VAR}${__KEY}=\"$__VALUE\"
		done < $__FILE
		IFS="$__OLD_IFS"
	fi
	
}

