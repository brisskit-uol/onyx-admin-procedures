#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Transfers a nominal based refined-metadata file plus all the generated enumerations 
# to suitable directories within the i2b2 VM
#
# Mandatory: the ONYX_ADMIN_PROCS_HOME environment variable to be set.
# Optional : the ONYX_PROCEDURES_WORKSPACE environment variable.
# The latter is an optional full path to a workspace area. If not set, defaults to a workspace
# within the procedures' home.
#
# USAGE: transfer-nominal-ontology.sh job-name
# Where: 
#   job-name is the job that groups the nominal ontology preparation
# Notes:
#   The appropriate destination within the i2b2 VM is set in the defaults.sh file.
#
# Author: Jeff Lusted (jl99@leicester.ac.uk)
#-----------------------------------------------------------------------------------------------
source $ONYX_ADMIN_PROCS_HOME/bin/common/setenv.sh
source $ONYX_ADMIN_PROCS_HOME/bin/common/functions.sh

#=======================================================================
# First, a lot of basic checks...
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
# Establish a log file for the job...
LOG_FILE=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$JOB_LOG_NAME

#
# We position on the metadata directory...
# It must exist!
METADIRECTORY=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$REFINED_METADATA_DIRECTORY
# echo $METADIRECTORY
if [ ! -d $METADIRECTORY ]
then
	print_message "Metadata directory $METADIRECTORY does not exist. Exiting..." $LOG_FILE
    exit 1
fi

ENUMS_METADIRECTORY=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$REFINED_METADATA_ENUMS_DIRECTORY
# echo $ENUMS_METADIRECTORY
if [ ! -d $ENUMS_METADIRECTORY ]
then
	print_message "Metadata directory $ENUMS_METADIRECTORY does not exist. Exiting..." $LOG_FILE
    exit 1
fi

#===========================================================================
# Print a banner for this step of the job.
#===========================================================================
print_banner $0 $JOB_NAME $LOG_FILE 

#===========================================================================
# The real work is about to start.
# And give the user a warning...
#=========================================================================== 
print_message "About to transfer nominal ontology to the i2b2 VM." $LOG_FILE
echo "This may take some minutes."

echo "source: $METADIRECTORY/$MAIN_REFINED_METADATA_FILE_NAME"
echo "destination: $I2B2_VM_NOMINAL_ONTOLOGY_DESTINATION"
echo "destination: $I2B2_VM_NOMINAL_ONTOLOGY_ENUMS_DESTINATION"
scp $METADIRECTORY/$MAIN_REFINED_METADATA_FILE_NAME $I2B2_VM_NOMINAL_ONTOLOGY_DESTINATION
exit_if_bad $? "Failed to transfer main nominal ontology file to i2b2 VM"

scp $ENUMS_METADIRECTORY/* $I2B2_VM_NOMINAL_ONTOLOGY_ENUMS_DESTINATION
exit_if_bad $? "Failed to transfer nominal generated enums to i2b2 VM"

#
# If we got this far, we must be successful...
print_message "Nominal ontology transferred correctly." $LOG_FILE
print_footer $0 $JOB_NAME $LOG_FILE