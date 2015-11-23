#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Simple script to execute an ANT procedure to do adhoc sql.
#
# The sqlaccess ANT procedure is in the ant subdirectory.
# The ANT target is given by the first argument passed, eg: pm to access the pm database
# (see the ant script for details) 
#-----------------------------------------------------------------------------------------------
source $ONYX_ADMIN_PROCS_HOME/bin/common/setenv.sh
source $ONYX_ADMIN_PROCS_HOME/bin/common/functions.sh  

#================================================
#  Accessing sql ...
#================================================
$ANT_HOME/bin/ant -propertyfile $ONYX_ADMIN_PROCS_HOME/config/config.properties \
                  -Dproc.home=$ONYX_ADMIN_PROCS_HOME \
                  -f $ONYX_ADMIN_PROCS_HOME/ant/${DB_TYPE}/sqlaccess.xml \
                  $1
exit_if_bad $? "Failed to submit sql" 
print_message "Success! " 
