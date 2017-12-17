#!/bin/bash


source $(dirname $0)/cfg.sh
source ${JEBACKUP_LIBS}/ansicolors.sh
source ${JEBACKUP_LIBS}/logger.sh
source ${JEBACKUP_LIBS}/assert.sh
source ${JEBACKUP_LIBS}/methods.sh

###############################################################################
# TEST
###############################################################################
test_parsing_methods() {
	get_available_method VAR_EXAMPLE $(dirname $0)/dataset/methods/*.sh
	assertEquals " foo new" "$VAR_EXAMPLE"
	assertEquals  "something" "$VAR_EXAMPLE_new_DESC"
	assertEquals  "nothing to say" "$VAR_EXAMPLE_foo_DESC"
	
}
set_logger_level $LOG_LEVEL_WARNING_CTE
source $SHUNIT2