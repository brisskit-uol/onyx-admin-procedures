#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Invokes the perl script treebuilderBrisskit.pl with a single comma-separated file
# and produces a refined metadata xml file corresponding to an i2b2 ontology.
#
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
# Retrieve the arguments into their variables...
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
# The codes file is...
RESEARCH_CODES_FILE=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$RESEARCH_CODES_DIRECTORY/code_file.txt
#
# And it must exist!
if [ ! -f $RESEARCH_CODES_FILE ]
then
	print_message "Error! Input codes file does not exist: $RESEARCH_CODES_FILE"
	exit 1
fi

METADIRECTORY=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$REFINED_METADATA_DIRECTORY
# echo $METADIRECTORY
if [ ! -d $METADIRECTORY ]
then
	mkdir -p $METADIRECTORY
    exit_if_bad $? "Failed to create metadata directory. $METADIRECTORY"
fi
#===========================================================================
# Print a banner for this step of the job.
#===========================================================================
print_banner $0 $JOB_NAME $LOG_FILE

#===========================================================================
# The real work is about to start.
# Give the user a warning...
#===========================================================================
print_message "About to build ontology file"
echo "This usually take some minutes."

#
# Do the business...
TAGGED_DIRECTORY=`pwd`
# echo $TAGGED_DIRECTORY
cd $METADIRECTORY
perl $ONYX_ADMIN_PROCS_HOME/bin/perl/BrisskitDAGbuilder.pl $RESEARCH_CODES_FILE \
                                                          onyx \
                                                          $NOMINAL_ONTOLOGY_ROOT
                                                          
# exit_if_bad $? "Failed to produce ontology file." 
cd $TAGGED_DIRECTORY        
#
# If we got this far, we must be successful...
print_footer $0 $JOB_NAME $LOG_FILE