#!/bin/bash
#
# Default settings used by scripts within the bin directory
# 
#-------------------------------------------------------------------

# Log file name:
export JOB_LOG_NAME=job.log

# Name of directory where a comma-separated file of research codes will be stored:
export RESEARCH_CODES_DIRECTORY=a-research-codes

# Default nominal ontology root. Used by the dag builder.
export NOMINAL_ONTOLOGY_ROOT=Nominal_Ontology

# Name of directory where onyx export file will be unzipped:
export ONYX_EXPORT_DIRECTORY=a-onyx-export

# Name of directory to hold first evolution of metadata files:
export METADATA_DIRECTORY=b-metadata

# Name of directory to hold second evolution of main metadata file:
export REFINED_METADATA_DIRECTORY=c-refined-metadata

# Name of directory to hold second evolution of main metadata enumeration files:
export REFINED_METADATA_ENUMS_DIRECTORY=d-refined-metadata-enums

# Name of directory to hold generated PDO xml files:
export PDO_DIRECTORY=f-pdo

# Name of directory to hold SQL inserts derived from PDO xml files:
export PDO_SQL_DIRECTORY=g-pdo-sql

# Max number of participants to be folded into one PDO xml file:
export BATCH_SIZE=50

# Name of config file used by nominal ontology extract and pdo build tool:
export EXPORT_METADATA_CONFIG=EXPORT-CONFIG-INTEGRATION.xml

# Name of file that holds the central metadata details:
export MAIN_REFINED_METADATA_FILE_NAME=refined-metadata.xml

# Name of the DB; can be either 'oracle' or 'sqlserver'
export DB_TYPE=sqlserver

# Paths to Onyx export directories
# The 'in' path is where Onyx drops an export file.
# The 'out' path is where we move an export file once it has been processed.
# The 'hold' directory holds export files whilst being processed.
export ONYX_EXPORT_IN_DIRECTORY=$ONYX_INSTALL_DIRECTORY/onyx-exports/in
export ONYX_EXPORT_OUT_DIRECTORY=$ONYX_INSTALL_DIRECTORY/onyx-exports/out
export ONYX_EXPORT_HOLD_DIRECTORY=$ONYX_INSTALL_DIRECTORY/onyx-exports/hold

# Name of directory to hold any zipped SQL test data (PDO based)
export ZIPPED_SQL_DIRECTORY=z-zipped-sql

export I2B2_VM_NOMINAL_ONTOLOGY_DESTINATION=integration@i2b2:/var/local/brisskit/i2b2/i2b2-admin-procedures-??/remote-holding-area/onyx/ontology
export I2B2_VM_NOMINAL_ONTOLOGY_ENUMS_DESTINATION=integration@i2b2:/var/local/brisskit/i2b2-admin-procedures-??/remote-holding-area/onyx/ontology-enums

export I2B2_VM_RESEARCH_ONTOLOGY_DESTINATION=integration@i2b2:/var/local/brisskit/i2b2-admin-procedures-??/remote-holding-area/onyx/ontology

# Custom space for the install workspace (if required)
# If not defined, defaults to ONYX_ADMIN_PROCS_HOME/work
#export ONYX_PROCEDURES_WORKSPACE=?

#---------------------------------------------------------------------------------
# Java, Ant and Tomcat home directories...
#---------------------------------------------------------------------------------
export JAVA_HOME=$ONYX_INSTALL_DIRECTORY/jdk
export ANT_HOME=$ONYX_INSTALL_DIRECTORY/ant
export TOMCAT_HOME=$ONYX_INSTALL_DIRECTORY/tomcat