#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Invokes the perl script onyxOntologyExtract.pl which extracts all codes from 
# a set of zip files held in a defined directory into a single comma-separated code_file.txt
#
#-----------------------------------------------------------------------------------------------
source $ONYX_ADMIN_PROCS_HOME/bin/common/setenv.sh
source $ONYX_ADMIN_PROCS_HOME/bin/common/functions.sh

print_extract_codes_usage() {
   echo " USAGE: 1-extract-codes.sh job-name zip-file-directory"
   echo " Where:"
   echo "   job-name is a suitable tag that groups all jobs associated with the overall workflow."
   echo "   zip-file-directory is a full path to a directory holding zip files corresponding to" 
   echo "   GUI designs of Onyx questionnaires."
}

#=======================================================================
# First, some basic checks...
#=======================================================================
#
# Check on the usage...
if [ ! $# -eq 2 ]
then
	echo "Error! Incorrect number of arguments"
	echo ""
	print_extract_codes_usage
	exit 1
fi

#
# Retrieve the arguments into their variables...
JOB_NAME=$1
ZIP_FILE_DIRECTORY=$2

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
# Now we create a working directory for this job step if it doesn't already exist
JOB_DIRECTORY=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME
# echo $JOB_DIRECTORY
if [ ! -d $JOB_DIRECTORY ]
then
	mkdir -p $JOB_DIRECTORY
    exit_if_bad $? "Failed to create working directory. $JOB_DIRECTORY"
fi

#
# The export directory is...
echo $RESEARCH_CODES_DIR
RESEARCH_CODES_DIR=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$RESEARCH_CODES_DIRECTORY
# echo $RESEARCH_CODES_DIR
#
# If it doesn't exist, we create it
if [ ! -d $RESEARCH_CODES_DIR ]
then
	mkdir -p $RESEARCH_CODES_DIR
	exit_if_bad $? "Failed to create directory $RESEARCH_CODES_DIR"
fi

#===========================================================================
# Print a banner for this step of the job.
#===========================================================================
print_banner $0 $JOB_NAME $LOG_FILE

#===========================================================================
# The real work is about to start.
# Give the user a warning...
#===========================================================================
print_message "About to code file from onyx questionnaire zips."
echo ""

echo $ZIP_FILE_DIRECTORY
echo $RESEARCH_CODES_DIR
#
# First copy across the relevant config file for the chosen ontologies...
cp $ONYX_ADMIN_PROCS_HOME/config/ontologies.xml $ONYX_ADMIN_PROCS_HOME/bin/perl
exit_if_bad $? "Failed to relocate the ontologies.xml file to the working directory."
#
# Do the business...
perl $ONYX_ADMIN_PROCS_HOME/bin/perl/onyxOntologyExtract.pl $ZIP_FILE_DIRECTORY -o $RESEARCH_CODES_DIR
exit_if_bad $? "Failed to produce comma separated code output."         
#
# If we got this far, we must be successful...
print_footer $0 $JOB_NAME $LOG_FILE
