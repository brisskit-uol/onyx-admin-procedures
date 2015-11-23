#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Orders current and past onyx export variables files and semantically compares them.
# There should be no difference unless there has been a deliberate design change in the questionnaire.
# This procedure shows up any change.
#
# Mandatory: the ONYX_ADMIN_PROCS_HOME environment variable to be set.
# Optional : the ONYX_PROCEDURES_WORKSPACE environment variable.
# The latter is an optional full path to a workspace area. If not set, defaults to a workspace
# within the procedures' home.
#
# USAGE: 2-check-variables job-name path-to-previous-onyx-data
# Where: 
#   current-job-name is a suitable tag to group all jobs associated with the overall workflow
#   path-to-previous-onyx-name is the directory of the previous onyx export file
# Notes:
#   The job-name is used to create a working directory for the overall workflow; eg:
#   ONYX_PROCEDURES_WORKSPACE/{job-name}/onyx-export-files
#   This working directory should NOT exist.
#
# Further tailoring can be achieved via the setenv.sh script.
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
PREVIOUS_ONYX_EXPORT_DIR=$2

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
# Now we position on a working directory for this job step.
CURRENT_ONYX_EXPORT_DIR=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/$ONYX_EXPORT_DIRECTORY

#===========================================================================
# Print a banner for this step of the job.
#===========================================================================
print_banner $0 $JOB_NAME $LOG_FILE 

#
# Here is the stylesheet...
STYLESHEET=$ONYX_ADMIN_PROCS_HOME/xslt/sortOnyxVariables.xsl

#
# Create temporary directories to store ordered variables files... 
if [ ! -d $ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/temp ]
then
    mkdir $ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/temp
    exit_if_bad $? "Failed to create working directory: $ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/temp"
fi

TEMP_CURRENT=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/temp/current-vars
if [ -d $TEMP_CURRENT ]
then
	rm -Rf $TEMP_CURRENT
fi
mkdir $TEMP_CURRENT
exit_if_bad $? "Failed to create working directory: $TEMP_CURRENT"

TEMP_PREVIOUS=$ONYX_PROCEDURES_WORKSPACE/$JOB_NAME/temp/previous-vars
if [ -d $TEMP_PREVIOUS ]
then
	rm -Rf $TEMP_PREVIOUS
fi
mkdir $TEMP_PREVIOUS
exit_if_bad $? "Failed to create working directory: $TEMP_PREVIOUS"

#===========================================================================
# The real work is about to start.
# And give the user a warning...
#=========================================================================== 
print_message "About to compare current onyx export variables files to previous export variables files." $LOG_FILE
echo "This should take under 60 seconds."
echo ""
echo "Detailed log messages are written to $LOG_FILE"
echo "If you want to see this during execution, try: tail -f $LOG_FILE"
echo ""

cd $CURRENT_ONYX_EXPORT_DIR

#
# Initialises the transformer and alphabetises the current xml variables files...
for d in $CURRENT_ONYX_EXPORT_DIR/*
do
	if [ -d $d ] 
	then
		echo "Processing directory: $(basename $d )"	
			$JAVA_HOME/bin/java \
       			  -cp $(for i in $ONYX_ADMIN_PROCS_HOME/lib/*.jar ; do echo -n $i: ; done). \
       			  net.sf.saxon.Transform \
       			  -xsl:$STYLESHEET \
       			  -s:$d/variables.xml \
       			  -o:$TEMP_CURRENT/$(basename $d )-curr-variables.xml
			exit_if_bad $? "Failed to produce ordered current variables file."
	fi
done
echo "Current xml variables files ordered successfully."
echo ""

#
# Initialises the transformer and alphabetises the previous xml variables files...
for dp in $PREVIOUS_ONYX_EXPORT_DIR/*
do
	if [ -d $dp ] 
	then
		echo "Processing directory: $(basename $dp )"
			$JAVA_HOME/bin/java \
					 -cp $(for i in $ONYX_ADMIN_PROCS_HOME/lib/*.jar ; do echo -n $i: ; done). \
				      net.sf.saxon.Transform \
				     -xsl:$STYLESHEET \
				     -s:$dp/variables.xml \
				     -o:$TEMP_PREVIOUS/$(basename $dp )-prev-variables.xml
			exit_if_bad $? "Failed to produce ordered previous variables file."
	fi
done
echo "Previous xml variables files ordered successfully."
echo ""
			
#
# Compares the alphabetised xml variables files...
for f in $TEMP_CURRENT/*
do
	if [ -f $f ]
	then
		echo "$(basename $f -curr-variables.xml )-prev-variables.xml"
        echo "$(basename $f)"
		$JAVA_HOME/bin/java \
				 -Dlog4j.configuration=file://$ONYX_ADMIN_PROCS_HOME/config/log4j.properties \
		         -cp $(for i in $ONYX_ADMIN_PROCS_HOME/lib/*.jar ; do echo -n $i: ; done). \
		         org.apache.DOMUtils \
		         "cmp" \
		         $TEMP_PREVIOUS/$(basename $f -curr-variables.xml )-prev-variables.xml \
		         $f
		 warning_if_bad_comment_if_good $? \
		           "Difference detected in variables files for $(basename $f -curr-variables.xml)." \
		           "Variables files for $(basename $f -curr-variables.xml) compared successfully." \
		           $LOG_FILE
		 echo ""
	fi
done
#
# If we got this far, we must be successful...
print_footer $0 $JOB_NAME $LOG_FILE
