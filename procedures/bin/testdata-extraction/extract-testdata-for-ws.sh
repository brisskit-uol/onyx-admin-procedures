#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Produces test data (nominal ontology and PDO) from an Onyx export file.
# The PDO is targetted for a ws upload.
#
# Mandatory: the ONYX_ADMIN_PROCS_HOME environment variable to be set.
# Optional : the ONYX_PROCEDURES_WORKSPACE environment variable.
# The latter is an optional full path to a workspace area. If not set, defaults to a workspace
# within the procedures' home.
#
# USAGE: extract-testdata-for-ws job-name zip-file -bid=aaaa-nnnn
# Where: 
#   job-name is a suitable tag to group all jobs associated with the overall workflow
#   zip-file is the onyx export file (zipped of course)
#   -bid=aaaa-nnnn is the starting brisskit id to be generated for the first fictitious participant.
#             For example, demo-0001
#             Subsequent generated id's will be sequentially incremented from this.
# Notes:
#   The job-name is used to create a working directory for the overall workflow; eg:
#   ONYX_PROCEDURES_WORKSPACE/{job-name}/onyx-export-files
#   This working directory should NOT exist.
#   It is your responsibility to know what the next new bid should be!
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

print_namespace_update_usage() {
	echo " USAGE: extract-testdata-for-ws.sh job-name zip-file -bid=aaaa-nnnn"
	echo " Where:" 
    echo "   job-name is a suitable tag to group all jobs associated with the overall workflow"
    echo "   zip-file is the onyx export file (zipped of course)"
    echo "   -bid=aaaa-nnnn is the starting brisskit id to be generated for the first fictitious participant."
    echo "             For example, demo-0001"
    echo "             Subsequent generated id's will be sequentially incremented from this."
    echo " Notes:"
    echo "   The job-name is used to create a working directory for the overall workflow;"
    echo "   eg: ONYX_PROCEDURES_WORKSPACE/{job-name}/onyx-export-files"
    echo "   This working directory should NOT exist."
    echo "   It is your responsibility to know what the next new bid should be!"
}

#=======================================================================
# First, some basic checks...
#=======================================================================
#
# Check on the usage...
if [ ! $# -eq 3 ]
then
	echo "Error! Incorrect number of arguments."
	echo ""
	print_namespace_update_usage
	exit 1
fi

#
# Retrieve the arguments into their variables...
JOB_NAME=$1
ONYX_EXPORT_FILE=$2
STARTING_BID=$3

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
print_message "About to produce test data from Onyx export file." $LOG_FILE
echo "This may take a few minutes."
echo ""
echo "Detailed log messages are written to $LOG_FILE"
echo "If you want to see this during execution, try: tail -f $LOG_FILE"
echo ""


#===========================================================================
# Unzip of export file plus update of name spaces.
#=========================================================================== 
print_message "About to unzip onyx export file and update the files with xml namespaces." $LOG_FILE
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


#===========================================================================
# Manipulation of export file to form composite data
#=========================================================================== 
print_message "" $LOG_FILE
print_message "About to alter export file to produce composite data." $LOG_FILE

$JAVA_HOME/bin/java \
         -Dlog4j.configuration=file://$ONYX_ADMIN_PROCS_HOME/config/log4j.properties \
         -cp $(for i in $ONYX_ADMIN_PROCS_HOME/lib/*.jar ; do echo -n $i: ; done). \
         org.brisskit.onyxexport.ParticipantCompositor \
         -config=$ONYX_ADMIN_PROCS_HOME/config/$EXPORT_METADATA_CONFIG \
         -export=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$ONYX_EXPORT_DIRECTORY \
         >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to produce composite data."


#===========================================================================
# Production of intermediate metadata.
#===========================================================================
print_message "" $LOG_FILE
print_message "About to produce intermediate metadata from onyx export files" $LOG_FILE

#
# Do the business...
$JAVA_HOME/bin/java \
         -Dlog4j.configuration=file://$ONYX_ADMIN_PROCS_HOME/config/log4j.properties \
         -cp $(for i in $ONYX_ADMIN_PROCS_HOME/lib/*.jar ; do echo -n $i: ; done). \
         org.brisskit.onyxexport.OnyxVariables2Metadata \
         -i=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$ONYX_EXPORT_DIRECTORY \
         -o=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$METADATA_DIRECTORY \
         >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to produce intermediate metadata files."         


#===========================================================================
# Production of refined metadata files
#===========================================================================
print_message "" $LOG_FILE
print_message "About to produce refined metadata files" $LOG_FILE

$JAVA_HOME/bin/java \
         -Dlog4j.configuration=file://$ONYX_ADMIN_PROCS_HOME/config/log4j.properties \
         -cp $(for i in $ONYX_ADMIN_PROCS_HOME/lib/*.jar ; do echo -n $i: ; done). \
         org.brisskit.onyxexport.MetadataRefiner \
         -config=$ONYX_ADMIN_PROCS_HOME/config/$EXPORT_METADATA_CONFIG \
         -i=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$METADATA_DIRECTORY \
         -n=$MAIN_REFINED_METADATA_FILE_NAME \
         -r=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$REFINED_METADATA_DIRECTORY \
         -e=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$REFINED_METADATA_ENUMS_DIRECTORY \
         >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to produce refined metadata files." 


#===========================================================================
# Production of PDO's
#===========================================================================
print_message "" $LOG_FILE
print_message "About to produce PDO test files." $LOG_FILE

#
# Do the business...
$JAVA_HOME/bin/java \
         -Dlog4j.configuration=file://$ONYX_ADMIN_PROCS_HOME/config/log4j.properties \
         -cp $(for i in $ONYX_ADMIN_PROCS_HOME/lib/*.jar ; do echo -n $i: ; done). \
         org.brisskit.onyxexport.OnyxData2Pdo \
         -export=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$ONYX_EXPORT_DIRECTORY \
         -ontology=nominal \
         -refine=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$REFINED_METADATA_DIRECTORY \
         -enum=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$REFINED_METADATA_ENUMS_DIRECTORY \
         -config=$ONYX_ADMIN_PROCS_HOME/config/$EXPORT_METADATA_CONFIG \
         -pdo=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$PDO_DIRECTORY \
         -name=$MAIN_REFINED_METADATA_FILE_NAME \
         -batch=$BATCH_SIZE \
         -test=yes \
         $STARTING_BID >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to produce pdo files."  

#
# If we got this far, we must be successful (?) ...
print_footer $0 $JOB_NAME $LOG_FILE       
