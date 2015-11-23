#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Unzips an onyx export file and updates the contained xml files with appropriate name spaces.
#
# Mandatory: the ONYX_ADMIN_PROCS_HOME environment variable to be set.
# Optional : the ONYX_PROCEDURES_WORKSPACE environment variable.
# The latter is an optional full path to a workspace area. If not set, defaults to a workspace
# within the procedures' home.
#
# USAGE: 1-namespace-update job-name zip-file
# Where: 
#   job-name is a suitable tag to group all jobs associated with the overall workflow
#   zip-file is the onyx export file (zipped of course)
# Notes:
#   The job-name is used to create a working directory for the overall workflow; eg:
#   ONYX_PROCEDURES_WORKSPACE/{job-name}/onyx-export-files
#   This working directory should NOT exist.
#
# Further tailoring can be achieved via the setenv.sh script.
#
# Author: Jeff Lusted (jl99@leicester.ac.uk)
#-----------------------------------------------------------------------------------------------
source $ONYX_ADMIN_PROCS_HOME/bin/common/setenv.sh
source $ONYX_ADMIN_PROCS_HOME/bin/common/functions.sh
#
# These are the relevant name spaces...
ENTITIES_NAMESPACE='http:\/\/brisskit.org\/xml\/onyx-entities\/v1.0\/oe'
VARIABLES_NAMESPACE='http:\/\/brisskit.org\/xml\/onyxvariables\/v1.0\/ov'
VALUES_NAMESPACE='http:\/\/brisskit.org\/xml\/onyxdata\/v1.0\/od'
SCHEMA_NAMESPACE='http:\/\/www.w3.org\/2001\/XMLSchema-instance'

#=======================================================================
# First, a lot of basic checks...
#=======================================================================
#
# Check on the usage...
if [ ! $# -eq 2 ]
then
	echo "Error! Incorrect number of arguments."
	echo ""
	print_usage
	exit 1
fi

#
# Retrieve the arguments into their variables...
JOB_NAME=$1
ONYX_EXPORT_FILE=$2

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
# Now we create a working directory for this job step.
# It must not exist!
WORK_DIR=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$ONYX_EXPORT_DIRECTORY
if [ -d $WORK_DIR ]
then
	print_message "Error! Working directory: $WORK_DIR" $LOG_FILE
	print_message "This directory already exists. Exiting..." $LOG_FILE
	exit 1
fi
mkdir -p $WORK_DIR
exit_if_bad $? "Failed to create working directory. $WORK_DIR"

#===========================================================================
# Print a banner for this step of the job.
#===========================================================================
print_banner $0 $JOB_NAME $LOG_FILE 

#
# The export file must exist...
if [ ! -e $ONYX_EXPORT_FILE ]
then
	print_message "Error! Zip file does not exist. Exiting..." $LOG_FILE
	exit 1
fi

#===========================================================================
# The real work is about to start.
# And give the user a warning...
#=========================================================================== 
print_message "About to unzip onyx export file and update the files with xml namespaces." $LOG_FILE
echo "This should take under 60 seconds."
echo ""
echo "Detailed log messages are written to $LOG_FILE"
echo "If you want to see this during execution, try: tail -f $LOG_FILE"
echo ""

#
# Copy the zip file to the working directory.
# Unzip it then delete the copy.
cd $WORK_DIR
cp $ONYX_EXPORT_FILE . >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to copy onyx export file: $ONYX_EXPORT_FILE" $LOG_FILE
unzip *.zip >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to unzip onyx export file: $ONYX_EXPORT_FILE" $LOG_FILE
rm -f *.zip >>$LOG_FILE 2>>$LOG_FILE
comment_if_bad $? "Failed to remove onyx zip file: $ONYX_EXPORT_FILE" $LOG_FILE

#
# Loop through the working directory updating each file with its namespace...
for d in $WORK_DIR/*
do
	if [ -d $d ] 
	then
		echo "Processing directory: $(basename $d )" >>$LOG_FILE 2>>$LOG_FILE
		for f in $d/*
		do
			if [ "$f" = "$d/entities.xml" ]
			then
				echo "   Entities file: $f" >>$LOG_FILE 2>>$LOG_FILE
				sed -e "s/<entities/<entities xmlns=\'$ENTITIES_NAMESPACE\' xmlns:xsi=\'$SCHEMA_NAMESPACE\'/" $f > $f.tmp 
				mv -f $f.tmp $f
				rm -f $f.tmp
			elif [ "$f" = "$d/variables.xml" ]
			then
				echo "   Variables file: $f" >>$LOG_FILE 2>>$LOG_FILE
				sed -e "s/<variables/<variables xmlns=\'$VARIABLES_NAMESPACE\' xmlns:xsi=\'$SCHEMA_NAMESPACE\'/" $f > $f.tmp 
				mv -f $f.tmp $f
				rm -f $f.tmp
			else
				echo "   Data file: $f" >>$LOG_FILE 2>>$LOG_FILE
				sed -e "s/<valueSet/<valueSet xmlns=\'$VALUES_NAMESPACE\' xmlns:xsi=\'$SCHEMA_NAMESPACE\'/" $f > $f.tmp 
				mv -f $f.tmp $f
				rm -f $f.tmp
			fi			
		done
	fi 
done
#
# If we got this far, we must be successful...
print_footer $0 $JOB_NAME $LOG_FILE