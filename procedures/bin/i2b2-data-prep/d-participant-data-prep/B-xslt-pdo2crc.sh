#!/bin/bash
#------------------------------------------------------------------------------------------------------------
# Takes pdo xml files and produces SQL inserts for the crc cell
#
# Prerequisites: The onyx2pdo script must have been successfully run.
#
# Mandatory: the following environment variables must be set
#            ONYX_ADMIN_PROCS_HOME, JAVA_HOME           
# Optional : the ONYX_PROCEDURES_WORKSPACE environment variable.
# The latter is an optional full path to a workspace area. If not set, defaults to a workspace
# within the procedures' home.
#
# USAGE: B-xslt-pdo2crc job-name 
# Where: 
#   job-name is a suitable tag that groups all jobs associated within the overall workflow
# Notes:
#   The job-name must be associated with the prerequisite run of the refine-metadata script.
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
INPUT_DIR=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$PDO_DIRECTORY
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
OUTPUT_DIR=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$PDO_SQL_DIRECTORY/$DB_TYPE/crccell
#
# And it must NOT exist!
if [ -d $OUTPUT_DIR ]
then
	print_message "Error! Output directory must not exist: $OUTPUT_DIR" $LOG_FILE
	print_message "Please check your job name: $JOB_NAME"
	exit 1
fi

#
# Make the output directory...
mkdir -p $OUTPUT_DIR
exit_if_bad $? "Failed to create output directory. $OUTPUT_DIR"

#
# Here is the stylesheet...
STYLESHEET=$ONYX_ADMIN_PROCS_HOME/xslt/$DB_TYPE/crc_pdo_${DB_TYPE}.xsl

#===========================================================================
# The real work is about to start.
# Give the user a warning...
#===========================================================================
print_message "About to produce observations data (et al) SQL for the crc cell" $LOG_FILE
echo "This may take some time."
echo ""
echo "Detailed log messages are written to $LOG_FILE"
echo "If you want to see this during execution, try: tail -f $LOG_FILE"
echo ""
#
# Do the business...
for f in $INPUT_DIR/*
do
	if [ ! $# -eq 0 ] 
	then
		echo "Processing file: $(basename $f .xml)" >>$LOG_FILE
		$JAVA_HOME/bin/java \
           -cp $(for i in $ONYX_ADMIN_PROCS_HOME/lib/*.jar ; do echo -n $i: ; done). \
           net.sf.saxon.Transform \
           -xsl:$STYLESHEET \
           -s:$f \
           -o:$OUTPUT_DIR/"$(basename $f .xml).sql" \
           -warnings:fatal >>$LOG_FILE 2>>$LOG_FILE
        exit_if_bad $? "Failed to produce observations data SQL for the crc cell."
	fi 
done
      
#
# If we got this far, we must be successful...
print_footer $0 $JOB_NAME $LOG_FILE
 