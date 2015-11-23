#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Takes nnnnnnnn.xml data files from an onyx export and produces one or more i2b2 PDO files.
#
# Prerequisites: The refine-metadata script must have been successfully run.
#
# Mandatory: the following environment variables must be set
#            ONYX_ADMIN_PROCS_HOME, JAVA_HOME
# Optional : the ONYX_PROCEDURES_WORKSPACE environment variable.
# The latter is an optional full path to a workspace area. If not set, defaults to a workspace
# within the procedures' home.
#
# USAGE: A-onyx2pdo job-name -pid=nnnn -eid=nnnn
# Where: 
#   job-name is a suitable tag that groups all jobs associated with the overall workflow
#   -pid=nnnn gives the starting number for patient identifiers
#   -eid=nnnn gives the starting number for event identifiers
# Notes:
#   The job-name must be associated with the prerequisite run of the namespace-update script.
#   The pid and eid parameter must be positive integers.
#   It is your responsibility to know what the next new pid or eid should be!
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
if [ ! $# -eq 3 ]
then
	echo "Error! Incorrect number of arguments"
	echo ""
	print_usage
	exit 1
fi

#
# Retrieve the arguments into their variables...
JOB_NAME=$1
STARTING_PID=$2
STARTING_EID=$3

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
# The export directory is...
EXPORT_DIR=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$ONYX_EXPORT_DIRECTORY
#
# And it must exist!
if [ ! -d $EXPORT_DIR ]
then
	print_message "Error! Input directory does not exist: $EXPORT_DIR"
	print_message "Please check your job name: $JOB_NAME. Exiting..."
	exit 1
fi

#===========================================================================
# Print a banner for this step of the job.
#===========================================================================
print_banner $0 $JOB_NAME $LOG_FILE

#
# The refined metadata directory is...
REFINED_METADATA_DIR=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$REFINED_METADATA_DIRECTORY
#
# And it must exist!
if [ ! -d $REFINED_METADATA_DIR ]
then
	print_message "Error! Refined metadata directory does not exist: $REFINED_METADATA_DIR"
	print_message "Please check your job name: $JOB_NAME."
	exit 1
fi

#
# The enum metadata directory is...
ENUM_METADATA_DIR=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$REFINED_METADATA_ENUMS_DIRECTORY
#
# And it must exist!
if [ ! -d $ENUM_METADATA_DIR ]
then
	print_message "Error! Enums metadata directory does not exist: $ENUM_METADATA_DIR"
	print_message "Please check your job name: $JOB_NAME."
	exit 1
fi

#
# And the output pdo directory is...
PDO_DIR=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$PDO_DIRECTORY
#
# And it must NOT exist!
if [ -d $PDO_DIR ]
then
	print_message "Error! Output directory exists: $PDO_DIR. Exiting..." $LOG_FILE
	exit 1
fi

#===========================================================================
# The real work is about to start.
# Give the user a warning...
#===========================================================================
print_message "About to produce pdo files from onyx export files"
echo "This could take some time."
echo ""
echo "Detailed log messages are written to $LOG_FILE"
echo "If you want to see this during execution, try: tail -f $LOG_FILE"
echo ""

#
# Do the business...
$JAVA_HOME/bin/java \
         -Dlog4j.configuration=file://$ONYX_ADMIN_PROCS_HOME/config/log4j.properties \
         -cp $(for i in $ONYX_ADMIN_PROCS_HOME/lib/*.jar ; do echo -n $i: ; done). \
         org.brisskit.onyxexport.OnyxData2Pdo \
         -export=$EXPORT_DIR \
         -ontology=nominal \
         -refine=$REFINED_METADATA_DIR \
         -enum=$ENUM_METADATA_DIR \
         -config=$ONYX_ADMIN_PROCS_HOME/config/$EXPORT_METADATA_CONFIG \
         -pdo=$PDO_DIR \
         -name=$MAIN_REFINED_METADATA_FILE_NAME \
         $STARTING_PID \
         $STARTING_EID \
         -batch=$BATCH_SIZE >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to produce pdo files."         
#
# If we got this far, we must be successful...
print_footer $0 $JOB_NAME $LOG_FILE
