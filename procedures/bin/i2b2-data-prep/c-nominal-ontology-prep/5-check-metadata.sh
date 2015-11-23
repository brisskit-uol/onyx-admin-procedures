#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Compares a refined metadata file against a previous refined metadata file.
#
# For a "nominal" ontology, there should be no difference between Onyx export runs 
# concerning metadata unless there has been a deliberate design change in the questionnaire. 
#
# For a "real" ontology, any difference between a current and previous ontologies should 
# presumably be known by the designer.

# However, this procedure can be used to show whether a change has occurred.
#
# Mandatory: the ONYX_ADMIN_PROCS_HOME environment variable to be set.
# Optional : the ONYX_PROCEDURES_WORKSPACE environment variable.
# The latter is an optional full path to a workspace area. If not set, defaults to a workspace
# within the procedures' home.
#
# USAGE: 5-check-metadata.sh job-name path-to-previous-metadata
# Where: 
#   job-name is a suitable tag to group all jobs associated with the overall workflow
#   path-to-previous-metadata is the full path of the previous refined metadata file
# Notes:
#   0 is returned if metadata compares equal
#   1 is returned if unequal or an internal error has occurred 
#
# Author: Will Lusted - will_lusted@hotmail.co.uk - in May 2012. Last modified 10/05/12.
#-----------------------------------------------------------------------------------------------
source $ONYX_ADMIN_PROCS_HOME/bin/common/setenv.sh
source $ONYX_ADMIN_PROCS_HOME/bin/common/functions.sh

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
PREVIOUS_METADATA=$2

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

#===========================================================================
# Print a banner for this step of the job.
#===========================================================================
print_banner $0 $JOB_NAME $LOG_FILE 

#
# The respective directories must exist...

#
# The input directory is...
INPUT_DIR=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$REFINED_METADATA_DIRECTORY
if [ ! -d $INPUT_DIR ]
then
	print_message "Error! Input metadata directory does not exist: $INPUT_DIR"
	print_message "Please check your job name: $JOB_NAME. Exiting..."
	exit 1
fi

#
# The input file is...
if [ ! -f $PREVIOUS_METADATA ]
then
	print_message "Error! Previous metadata file does not exist: $PREVIOUS_METADATA"
	print_message "Please check your job name: $JOB_NAME. Exiting..."
	exit 1
fi

#
# Here is the stylesheet...
STYLESHEET=$ONYX_ADMIN_PROCS_HOME/xslt/sortRefinedMetadata.xsl

#===========================================================================
# The real work is about to start.
# And give the user a warning...
#=========================================================================== 
print_message "About to compare current metadata to previous." $LOG_FILE
echo "This should take under 60 seconds."
echo ""
echo "Detailed log messages are written to $LOG_FILE"
echo "If you want to see this during execution, try: tail -f $LOG_FILE"
echo ""

#
# Create temporary directory to store ordered metadata files... 
if [ ! -d $ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/temp ]
then
    mkdir $ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/temp
    exit_if_bad $? "Failed to create working directory: $ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/temp"
fi

TEMP_META_DIR=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/temp/refined-meta
if [ -d $TEMP_META_DIR ]
then
	rm -Rf $TEMP_META_DIR
fi
mkdir $TEMP_META_DIR
exit_if_bad $? "Failed to create working directory: $TEMP_META_DIR"

#
# Initialises the transformer and produces two ordered xml output files...
$JAVA_HOME/bin/java \
        -cp $(for i in $ONYX_ADMIN_PROCS_HOME/lib/*.jar ; do echo -n $i: ; done). \
         net.sf.saxon.Transform \
         -xsl:$STYLESHEET \
         -s:$INPUT_DIR/$MAIN_REFINED_METADATA_FILE_NAME \
         -o:$TEMP_META_DIR/current_metadata.xml
exit_if_bad $? "Failed to produce ordered current output file."

$JAVA_HOME/bin/java \
        -cp $(for i in $ONYX_ADMIN_PROCS_HOME/lib/*.jar ; do echo -n $i: ; done). \
         net.sf.saxon.Transform \
         -xsl:$STYLESHEET \
         -s:$PREVIOUS_METADATA \
         -o:$TEMP_META_DIR/previous_metadata.xml
exit_if_bad $? "Failed to produce ordered previous output file."

$JAVA_HOME/bin/java \
		 -Dlog4j.configuration=file://$ONYX_ADMIN_PROCS_HOME/config/log4j.properties \
         -cp $(for i in $ONYX_ADMIN_PROCS_HOME/lib/*.jar ; do echo -n $i: ; done). \
         org.apache.DOMUtils \
         "cmp" \
         $TEMP_META_DIR/previous_metadata.xml \
         $TEMP_META_DIR/current_metadata.xml >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Difference detected in metadata. Consult the log file."

#
# If we got this far, we must be successful...
print_message "" $LOG_FILE
print_message "Metadata compared successfully" $LOG_FILE
print_footer $0 $JOB_NAME $LOG_FILE