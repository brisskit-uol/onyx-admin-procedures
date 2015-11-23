#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Uploads participant data for an i2b2 project using a Web Service route.
#
# Prerequisites: 
#   (1) Execution of metadata-upload-sql.sh and its prerequisites (or equivalent)
#   (2) Settings within the directory ONYX_ADMIN_PROCS_HOME/config/config.properties
#   (3) Production of one or more PDO files
#
# Mandatory: the ONYX_ADMIN_PROCS_HOME environment variable to be set.
# Optional : the ONYX_PROCEDURES_WORKSPACE environment variable.
# The latter is an optional full path to a workspace area. If not set, defaults to a workspace
# within the procedures' home.
#
# USAGE: participant-upload-sql.sh job-name
# Where: 
#   job-name is a suitable tag that groups all jobs associated with the overall workflow
# Notes:
#   The job-name is used to find the working directory for the overall workflow; eg:
#   ONYX_PROCEDURES_WORKSPACE/{job-name}
#   This working directory must already exist. 
#   It should be the working directory associated with creating the pdo sql.
#
# Further tailoring can be achieved via the defaults.sh script.
#
# NB: The present script sets the import append flag to false.
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
	echo "Error! Incorrect number of arguments."
	echo ""
	print_usage
	exit 1
fi

#
# Retrieve job-name into its variable...
JOB_NAME=$1

#
# It is possible to set your own procedures workspace.
# But if it doesn't exist, we create one for you within the procedures home...
if [ -z $ONYX_PROCEDURES_WORKSPACE ]
then
	ONYX_PROCEDURES_WORKSPACE=$ONYX_ADMIN_PROCS_HOME/work
fi

#
# Establish a log file for the job...
LOG_FILE=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$JOB_LOG_NAME

#
# The working directory must already exist...
WORK_DIR=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME
if [ ! -d $WORK_DIR ]
then
	print_message "Error! Working directory does not exist: $WORK_DIR"
	print_message "Please check your job name: $JOB_NAME. Exiting..."
	exit 1
fi

#
# The input directory is...
INPUT_DIR=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$PDO_DIRECTORY
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

#===========================================================================
# The real work is about to start.
# Give the user a warning...
#=========================================================================== 
print_message "About to upload participant data via web service route" $LOG_FILE
echo "This should take some minutes."
echo ""
echo "Detailed log messages are written to $LOG_FILE"
echo "If you want to see this during execution, try: tail -f $LOG_FILE"
echo ""

#===========================================================================
# IMPORT PARTICIPANT DATA TO CRC CELL.
# NB: There can be more than one PDO file in the input directory!
#===========================================================================
#
# Do the business...
for f in $INPUT_DIR/*
do
	if [ ! $# -eq 0 ] 
	then
		echo "Processing file: $(basename $f)" >>$LOG_FILE
		
		$JAVA_HOME/bin/java \
         -Dlog4j.configuration=file://$ONYX_ADMIN_PROCS_HOME/config/log4j.properties \
         -Djava.endorsed.dirs=$ONYX_ADMIN_PROCS_HOME/endorsed-lib \
         -cp $(for i in $ONYX_ADMIN_PROCS_HOME/lib/*.jar ; do echo -n $i: ; done). \
         org.brisskit.i2b2.dataimport.ImportPdo \
         -config=$ONYX_ADMIN_PROCS_HOME/config/config.properties \
         -import=$f \
		 -append=false \
         >>$LOG_FILE 2>>$LOG_FILE
         
        exit_if_bad $? "Failed to import $(basename $f) to crc cell." 
        echo "File: $(basename $f) uploaded and processed." >>$LOG_FILE
	fi 
done

print_message "Success! Participant data imported into crc cell." $LOG_FILE

#=========================================================================
# If we got this far, we must be successful (hopefully) ...
#=========================================================================
echo "Please check JBoss log and i2b2 database to be sure."
print_footer $0 $JOB_NAME $LOG_FILE