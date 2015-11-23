#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Takes variables.xml files from an onyx export and produces simplified metadata files.
#
# Prerequisite: The namespace-update script must have been successfully run.
#
# Mandatory: the following environment variables must be set
#            ONYX_ADMIN_PROCS_HOME, JAVA_HOME
# Optional : the ONYX_PROCEDURES_WORKSPACE environment variable.
# The latter is an optional full path to a workspace area. If not set, defaults to a workspace
# within the procedures' home.
#
# USAGE: 3-onyx2metadata job-name 
# Where: 
#   job-name is a suitable tag that groups all jobs associated with the overall workflow
# Notes:
#   The job-name must be associated with the prerequisite run of the namespace-update script.
#
# Author: Jeff Lusted (jl99@leicester.ac.uk)
#-----------------------------------------------------------------------------------------------
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
# We use the log file for the job...
LOG_FILE=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$JOB_LOG_NAME

#
# The input directory is...
INPUT_DIR=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$ONYX_EXPORT_DIRECTORY
#
# And it must exist!
if [ ! -d $INPUT_DIR ]
then
	print_message "Error! Input directory does not exist: $INPUT_DIR"
	print_message "Please check your job name: $JOB_NAME. Exiting..."
	exit 1
fi

#===========================================================================
# Print a banner for this step of the job.
#===========================================================================
print_banner $0 $JOB_NAME $LOG_FILE

#
# And the output directory is...
OUTPUT_DIR=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$METADATA_DIRECTORY
#
# And it must NOT exist!
if [ -d $OUTPUT_DIR ]
then
	print_message "Error! Output directory exists: $OUTPUT_DIR." $LOG_FILE
	print_message "Please check your job name: $JOB_NAME. Exiting..."
	exit 1
fi

#===========================================================================
# The real work is about to start.
# And give the user a warning...
#===========================================================================
print_message "About to produce intermediate metadata from onyx export files"
echo "This should take under 60 seconds."
echo ""
echo "Detailed log messages are written to $LOG_FILE"
echo "If you want to see this during execution, try: tail -f $LOG_FILE"
echo ""
#
# Do the business...
$JAVA_HOME/bin/java \
         -Dlog4j.configuration=file://$ONYX_ADMIN_PROCS_HOME/config/log4j.properties \
         -cp $(for i in $ONYX_ADMIN_PROCS_HOME/lib/*.jar ; do echo -n $i: ; done). \
         org.brisskit.onyxexport.OnyxVariables2Metadata \
         -i=$INPUT_DIR \
         -o=$OUTPUT_DIR >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to produce intermediate metadata files."         
#
# If we got this far, we must be successful...
print_footer $0 $JOB_NAME $LOG_FILE
