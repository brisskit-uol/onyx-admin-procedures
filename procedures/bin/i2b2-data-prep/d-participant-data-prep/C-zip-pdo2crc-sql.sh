#!/bin/bash
#------------------------------------------------------------------------------------------------------------
# Zips the pdo SQL inserts for the crc cell
#
# Anticipated use: for moving test data around between systems.
#
# Prerequisites: relevant successful runs of 
#    (1) The onyx2do-testdata.sh script (or equivalent)
#    (2) The xslt-pdo2crc.sh script (or equivalent) 
#
# Mandatory: the following environment variables must be set
#    ONYX_ADMIN_PROCS_HOME         
# Optional : the ONYX_PROCEDURES_WORKSPACE environment variable.
# The latter is an optional full path to a workspace area. If not set, defaults to a workspace
# within the procedures' home.
#
# USAGE: C-zip-pdo2crc-sql job-name 
# Where: 
#   job-name is a suitable tag that groups all jobs associated within the overall workflow
# Notes:
#   The job-name must be associated with the prerequisite run of the onyx2pdo-testdata script.
#
# Author: Jeff Lusted (jl99@leicester.ac.uk)
#-------------------------------------------------------------------------------------------------------------
source $ONYX_ADMIN_PROCS_HOME/bin/common/setenv.sh
source $ONYX_ADMIN_PROCS_HOME/bin/common/functions.sh

#=======================================================================
# First, some basic checks...
#=======================================================================
#
# Check on the usage...
if [ ! $# -eq 1 ]
then
	echo "Error! Incorrect number of arguments"
	echo ""
	print_usage
	exit 1
fi

#
# Retrieve the argument into its variable...
JOB_NAME=$1

#
# It is possible to set your own procedures workspace.
# But if it doesn't exist, we create one for you within the procedures home...
if [ -z $ONYX_PROCEDURES_WORKSPACE ]
then
	ONYX_PROCEDURES_WORKSPACE=$ONYX_ADMIN_PROCS_HOME/work
fi

#
# The input directory is...
INPUT_DIR=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$PDO_SQL_DIRECTORY
#
# And it must exist!
if [ ! -d $INPUT_DIR ]
then
	echo "Error! Input directory does not exist: $INPUT_DIR"
	echo "Please check your job name: $JOB_NAME. Exiting..."
	exit 1
fi

#
# We use the log file for the job...
LOG_FILE=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$JOB_LOG_NAME

#===========================================================================
# Print a banner for this step of the job.
#===========================================================================
print_banner $0 $JOB_NAME $LOG_FILE

#
# And the output directory is...
OUTPUT_DIR=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$ZIPPED_SQL_DIRECTORY

#
# We create it if it does not exist!
if [ ! -d $OUTPUT_DIR ]
then
	mkdir -p $OUTPUT_DIR
	exit_if_bad $? "Failed to create output directory. $OUTPUT_DIR"
fi

#===========================================================================
# The real work is about to start.
# Give the user a warning...
#===========================================================================
print_message "About to zip pdo SQL for the crc cell" $LOG_FILE
echo "Should take less than a minute."
echo ""
echo "Detailed log messages are written to $LOG_FILE"
echo "If you want to see this during execution, try: tail -f $LOG_FILE"
echo ""
NOW=$(date +%Y%m%d-%H:%M:%S)
cd $INPUT_DIR
#
# Do the business...
##
## got this far. File name needs to be time-stamped for uniqueness...
zip -9 -r $OUTPUT_DIR/pdo-crc-sql-$NOW.zip \
    ./ \
    -x *.svn* \
    >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to zip pdo SQL for the crc cell."
print_message "Success! Zipped pdo SQL for the crc cell." $LOG_FILE
     
#
# If we got this far, we must be successful...
print_footer $0 $JOB_NAME $LOG_FILE
 