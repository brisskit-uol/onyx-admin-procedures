#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Takes intermediate metadata files and produces many refined metadata files.
# Currently over 600 refined metadata files are produced.
# The main file is named RefinedMetadata.xml, the rest are enumerated concepts.
#
# Prerequisite: The onyx2metadata script must have been successfully run.
#
# Mandatory: the following environment variables must be set
#            ONYX_ADMIN_PROCS_HOME, JAVA_HOME             
# Optional : the ONYX_PROCEDURES_WORKSPACE environment variable.
# The latter is an optional full path to a workspace area. If not set, defaults to a workspace
# within the procedures' home.
#
# USAGE: 4-refine-metadata job-name 
# Where: 
#   job-name is a suitable tag that groups all jobs associated within the overall workflow
# Notes:
#   The job-name must be associated with the prerequisite run of the onyx2metadata script.
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
INPUT_DIR=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$METADATA_DIRECTORY
#
# And it must exist!
if [ ! -d $INPUT_DIR ]
then
	echo "Error! Input directory does not exist: $INPUT_DIR"
	echo "Please check your job name: $JOB_NAME. Exiting..."
	exit 1
fi

#===========================================================================
# Print a banner for this step of the job.
#===========================================================================
print_banner $0 $JOB_NAME $LOG_FILE

#
# And the output directories are...
REFINE_DIR=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$REFINED_METADATA_DIRECTORY
ENUM_DIR=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$REFINED_METADATA_ENUMS_DIRECTORY
#
# And they must NOT exist!
if [ -d $REFINE_DIR ]
then
	print_message "Error! Refine metadata output directory already exists: $REFINE_DIR." $LOG_FILE
	exit 1
fi
if [ -d $ENUM_DIR ]
then
	print_message "Error! Enum metadata output directory already exists: $ENUM_DIR." $LOG_FILE
	exit 1
fi

#===========================================================================
# The real work is about to start.
# give the user a warning...
#===========================================================================
print_message "About to produce refined metadata files"
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
         org.brisskit.onyxexport.MetadataRefiner \
         -config=$ONYX_ADMIN_PROCS_HOME/config/$EXPORT_METADATA_CONFIG \
         -i=$INPUT_DIR \
         -n=$MAIN_REFINED_METADATA_FILE_NAME \
         -r=$REFINE_DIR \
         -e=$ENUM_DIR \
         >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to produce refined metadata files." 
       
#
# If we got this far, we must be successful...
print_footer $0 $JOB_NAME $LOG_FILE
