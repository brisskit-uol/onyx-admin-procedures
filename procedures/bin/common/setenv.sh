#!/bin/bash
#
# Basic environment variables for Onyx
# 
# Invocation within another sh script should be:
# source $ONYX_ADMIN_PROCS_HOME/setenv.sh
#
#-------------------------------------------------------------------
if [ -z $ONYX_ADMIN_DEFAULTS_DEFINED ]
then
	export ONYX_ADMIN_DEFAULTS_DEFINED=true	
	source $ONYX_ADMIN_PROCS_HOME/config/defaults.sh	
fi


