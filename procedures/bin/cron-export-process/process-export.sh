#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Processes onyx export files end to end.
#
# IMPORTANT. The first line (/var/local/brisskit/onyx/set.sh)
#            must refer to the absolute location of the set.sh file
#            as this script is fired up by a cron job.
#            Edit this script to correct the location if need be.
# 
# To be fired off by a cron job.
# (1) Picks up an export file from the 'in' directory.
# (2) Runs through the procedures for preparing an export file (ontology stages).
# (3) Produces a suitable PDO (or more than one?).
# (4) Uploads all of these PDO's to i2b2.
# (5) Moves the export file to the 'out' directory.
# 
# Mandatory: the ONYX_ADMIN_PROCS_HOME environment variable to be set.
# Optional : the ONYX_PROCEDURES_WORKSPACE environment variable.
# The latter is an optional full path to a workspace area. If not set, defaults to a workspace
# within the procedures' home.
#
# USAGE: process-export
# Note: there are no input parameters.
#
# Author: Jeff Lusted (jl99@leicester.ac.uk)
#-----------------------------------------------------------------------------------------------
source /var/local/brisskit/onyx/set.sh
source $ONYX_ADMIN_PROCS_HOME/bin/common/setenv.sh
source $ONYX_ADMIN_PROCS_HOME/bin/common/functions.sh

#=======================================================================
# First, some basic checks...
#=======================================================================
#
# Make up a job name dependent on some timestamp...
JOB_NAME=`date +%Y%m%d-%T`

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
# The real work is about to start.
#=========================================================================== 
#
# Loop through the 'in' directory looking for an export file...
for f in $ONYX_EXPORT_IN_DIRECTORY/*
do
	if [ -f $f ] 
	then
	    # Move the file to the 'hold' directory
		mv $f $ONYX_EXPORT_HOLD_DIRECTORY
		# steps here to process the export file...
		$ONYX_ADMIN_PROCS_HOME/bin/i2b2-data-prep/b-export-file-prep/1-namespace-update.sh $JOB_NAME $ONYX_EXPORT_HOLD_DIRECTORY/$(basename $f)
	    $ONYX_ADMIN_PROCS_HOME/bin/i2b2-data-prep/c-nominal-ontology-prep/3-onyx2metadata.sh $JOB_NAME
	    $ONYX_ADMIN_PROCS_HOME/bin/i2b2-data-prep/c-nominal-ontology-prep/4-refine-metadata.sh $JOB_NAME
	    $ONYX_ADMIN_PROCS_HOME/bin/i2b2-data-prep/d-participant-data-prep/A-onyx2pdo-WEBSERVICE.sh $JOB_NAME
	    $ONYX_ADMIN_PROCS_HOME/bin/i2b2-participant-upload/participant-upload-ws.sh $JOB_NAME
	    # Finally move the export file to the 'out' directory and finish
	    mv $ONYX_EXPORT_HOLD_DIRECTORY/$(basename $f) $ONYX_EXPORT_OUT_DIRECTORY
	else
		break
	fi
done