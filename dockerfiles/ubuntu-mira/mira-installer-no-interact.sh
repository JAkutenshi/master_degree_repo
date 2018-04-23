#!/bin/bash

###############################################################################

confirm()
{
	echo -n "$1 ? (n) "
	read ans
	case "$ans" in
	y|Y|yes|YES|Yes) return 0 ;;
	*) return 1 ;;
	esac
}

infoMsg()
{
	echo "$1" | tee -a $LOG_FILE
}

fatalInfoMsg()
{
	echo $1 >> $LOG_FILE
	echo ""
	echo "....."
	tail -n20 $LOG_FILE
	echo ""
	echo "$1 For more details look into $LOG_FILE"
	exit -1
}

installPackage()
{
	infoMsg "INFO: Install $1..."
	$BOOTSTRAP_DIR/bin/mirapackage -P $INSTALL_DIR -I $1 2>&1 | tee -a $LOG_FILE
	if [ $PIPESTATUS -ne 0 ] ; then
		fatalInfoMsg "FATAL: Install $1 failed."
	fi
}

###############################################################################

echo "************************************************************************"
echo "*"
echo "* This is the MIRA source installer. It will download and compile a"
echo "* basic configuration of MIRA on your system."
echo "*"
echo "************************************************************************"
echo ""

INSTALL_DIR_DEFAULT=`pwd`/mira
mkdir `pwd`/mira
#read -p "Please input the installation directory. Enter=default($INSTALL_DIR_DEFAULT): " INSTALL_DIR_INPUT

#if [ -z "$INSTALL_DIR_INPUT" ]; then
INSTALL_DIR_INPUT=$INSTALL_DIR_DEFAULT
#fi

# normalize the path
INSTALL_DIR=$(cd $(eval "dirname ${INSTALL_DIR_INPUT}");pwd)/$(eval "basename ${INSTALL_DIR_INPUT}")

#######################################################################
# Variables

BOOTSTRAP_DIR=$INSTALL_DIR/bootstrap

TARGET="release"
JOB_CNT=1
JOB_CNT_DEFAULT=2
DOWNLOAD_DIR=$INSTALL_DIR
LOG_FILE="$INSTALL_DIR/install.log"
STAGE_FILE="$INSTALL_DIR/install.stage"
START_STAGE=1
END_STAGE=13

MIRAENV_URL="ftp://mira-project.org/repos/MIRA-main/src/env/latest/MIRAenvironment.zip"
MIRABASE_URL="ftp://mira-project.org/repos/MIRA-main/src/base/latest/MIRABase.zip"
MIRAPACKAGE_URL="ftp://mira-project.org/repos/MIRA-main/src/tools/mirapackage/latest/MIRAPackage.zip"

#######################################################################

# check if the directory already exists
#if [ -d $INSTALL_DIR ] ; then
#	#exists check for install.stage file
#	if [ -e $STAGE_FILE ] ; then
#		# stage file exists retrieve last stage
#		read -r LAST_STAGE < $STAGE_FILE
#		if [ -n $LAST_STAGE ] ; then
#			echo ""
#			if confirm "The Directory $INSTALL_DIR already exists and contains a previously started installation. Continue this installation?" ; then 
#				START_STAGE=$LAST_STAGE
#			else
#				rm -rf $INSTALL_DIR
#			fi
#		else
#			echo ""
#			if confirm "Directory $INSTALL_DIR already exists. All data in that directory will be lost! Continue?" ; then
#				echo "Removing old directory content..."
#				rm -rf $INSTALL_DIR
#			else
# 				exit
#			fi
#		fi
#	else
#		echo ""
#		if confirm "Directory $INSTALL_DIR already exists. All data in that directory will be lost! Continue?" ; then
#			echo "Removing old directory content..."
#			rm -rf $INSTALL_DIR
#		else
# 			exit
#		fi
#	fi
#fi

echo ""
#read -p "Please enter number of parallel build jobs for 'make -jN'. Enter=default($JOB_CNT_DEFAULT): " JOB_CNT
#if [ -z "$JOB_CNT" ]; then
JOB_CNT=$JOB_CNT_DEFAULT
#fi

expr $JOB_CNT + 1 > /dev/null
if [ $? -ne 0 ] ; then
	echo "FATAL: Invalid number of build jobs. Abort!"
	exit
fi

echo ""

for (( i=$START_STAGE; i<=$END_STAGE; i++ ))
do
	case $i in
	1)
		#######################################################################
		# Create directory

		echo "INFO: Create install directory..."

		# create the directory
		mkdir -p $INSTALL_DIR
		if [ $? -ne 0 ] ; then
			echo "FATAL: Failed to create directory $INSTALL_DIR. Abort!"
			exit -1
		fi

		# create a bootstrap directory
		mkdir -p $BOOTSTRAP_DIR

		# Create log file
		touch $LOG_FILE
		touch $STAGE_FILE;;
	2)
		#######################################################################
		# Download MIRAEnvironment (for bootstrap environment)

		infoMsg "INFO: Downloading MIRAEnvironment..."
		wget -q $MIRAENV_URL -P $DOWNLOAD_DIR
		if [ $? -ne 0 ] ; then
			fatalInfoMsg "FATAL: Failed to download $MIRAENV_URL"
		fi;;
	3)
		#######################################################################
		# Download MIRABase (for bootstrap environment)

		infoMsg "INFO: Downloading MIRABase..."
		wget -q $MIRABASE_URL -P $DOWNLOAD_DIR
		if [ $? -ne 0 ] ; then
			fatalInfoMsg "FATAL: Failed to download $MIRABASE_URL"
		fi;;
	4)
		#######################################################################
		# Download MIRAPackage (for bootstrap environment)

		infoMsg "INFO: Downloading MIRAPackage..."
		wget -q $MIRAPACKAGE_URL -P $DOWNLOAD_DIR
		if [ $? -ne 0 ] ; then
			fatalInfoMsg "FATAL: Failed to download $MIRAPACKAGE_URL"
		fi;;
	5)
		#######################################################################
		# Create the MIRA bootstrap environment
		
		infoMsg "INFO: Unzip MIRAenvironment..."
		# unzip MIRAenvironment
		cd $BOOTSTRAP_DIR
		unzip -q $DOWNLOAD_DIR/MIRAenvironment.zip

		# Since MIRAenvironment.zip contains a path 'MIRA', we have to move all
		# files to $BOOTSTRAP_DIR
		mv MIRA/* $BOOTSTRAP_DIR
		rmdir MIRA

		# Clean up
		rm $DOWNLOAD_DIR/MIRAenvironment.zip;;
	6)
		#######################################################################
		# Unpack MIRABase in bootstrap environment

		infoMsg "INFO: Unzip MIRABase..."
		# unzip MIRABase
		cd $BOOTSTRAP_DIR
		unzip -q $DOWNLOAD_DIR/MIRABase.zip

		# Clean up
		rm $DOWNLOAD_DIR/MIRABase.zip;;
	7)
		#######################################################################
		# Unpack MIRAPackage in bootstrap environment

		infoMsg "INFO: Unzip MIRAPackage..."
		# unzip MIRAPackage
		cd $BOOTSTRAP_DIR/tools
		unzip -q $DOWNLOAD_DIR/MIRAPackage.zip

		# Clean up
		rm $DOWNLOAD_DIR/MIRAPackage.zip;;
	8)
		#######################################################################
		# Bootstrapping mira base system

		infoMsg "INFO: Bootstrapping MIRA base system. Please wait (~5min, Dual-core 2GHz)..."
		cd $BOOTSTRAP_DIR

		export MIRA_PATH="$BOOTSTRAP_DIR"

		# Step 1/3 - Create the build environment
		infoMsg "INFO: Bootstrapping 1/3: Perform the cmake step..."
		make depend_$TARGET >> $LOG_FILE 2>&1
		if [ $PIPESTATUS -ne 0 ] ; then
			fatalInfoMsg "FATAL: cmake step failed."
		fi;;
	9)
		#######################################################################
		# Bootstrapping mira base system
		# Step 2/3 - Build only MIRABase using -j1 to ensure, that all external dependencies
		# are correctly downloaded.

		cd $BOOTSTRAP_DIR
		export MIRA_PATH="$BOOTSTRAP_DIR"

		infoMsg "INFO: Bootstrapping 2/3: Building MIRABase..."
		make MIRABase_$TARGET 2>&1 | tee -a $LOG_FILE | \
			grep --line-buffered "%]" | awk '{printf("\b\b\b\b\b\b\b%6s",substr($0,0,6))}'
		if [ $PIPESTATUS -ne 0 ] ; then
			fatalInfoMsg "FATAL: Building MIRABase failed."
		fi
		echo "";;
	10)
		#######################################################################
		# Bootstrapping mira base system
		# Step 3/3 - Build MIRAPackage using -jN

		cd $BOOTSTRAP_DIR
		export MIRA_PATH="$BOOTSTRAP_DIR"

		infoMsg "INFO: Bootstrapping 3/3: Building MIRAPackage..."
		make -j$JOB_CNT mirapackage_$TARGET 2>&1 | tee -a $LOG_FILE | \
			grep --line-buffered "%]" | awk '{printf("\b\b\b\b\b\b\b%6s",substr($0,0,6))}'
		if [ $PIPESTATUS -ne 0 ] ; then
			fatalInfoMsg "FATAL: Build step failed."
		fi

		# Delete package files in BOOTSTRAP directory to avoid the mirapackage
		# will find them.
		find $BOOTSTRAP_DIR -name "*.package" | xargs rm -f

		echo "";;
	11)
		#######################################################################
		# Use mirapackage from BOOTSTRAP directory to download and all packages

		cd $BOOTSTRAP_DIR
		export MIRA_PATH="$BOOTSTRAP_DIR:$INSTALL_DIR"

		if [ -f ${HOME}/.config/mira/mirapackage.xml ] ; then
#			if confirm "An existing configuration of mirapackage was found. Should the installer delete this to get a clean environment" ; then
				infoMsg "INFO: Clear repositories."
				$BOOTSTRAP_DIR/bin/mirapackage --clearrepos 2>&1 | tee -a $LOG_FILE
#			fi
		fi

		# Ignore error here, which may caused by invalid repo configuration
		#if [ $PIPESTATUS -ne 0 ] ; then
		#	fatalInfoMsg "FATAL: Clear repositories failed."
		#fi

		infoMsg "INFO: Add installation repository"
		$BOOTSTRAP_DIR/bin/mirapackage --addurl ftp://mira-project.org/repos/MIRA-main/src/MIRA-main.repo 2>&1 | tee -a $LOG_FILE
		if [ $PIPESTATUS -ne 0 ] ; then
			fatalInfoMsg "FATAL: Add installation repository failed."
		fi

		infoMsg "INFO: Reindex installation repository"
		$BOOTSTRAP_DIR/bin/mirapackage --reindex 2>&1 | tee -a $LOG_FILE
		if [ $PIPESTATUS -ne 0 ] ; then
			fatalInfoMsg "FATAL: Reindex installation repository failed."
		fi

		installPackage MIRAenvironment
		# Since MIRAenvironment.zip contains a path 'MIRA', we have to move all
		# files to $INSTALL_DIR
		mv $INSTALL_DIR/MIRA/* $INSTALL_DIR
		rmdir $INSTALL_DIR/MIRA

		installPackage MIRABase
		installPackage MIRAPackage

		installPackage MIRAFramework
		installPackage GUIWidgets

		installPackage CommonCodecs
		installPackage CommonVisualization
		installPackage PlotVisualization
		installPackage Localization
		installPackage Navigation
		installPackage RigidModel
		installPackage RobotDataTypes
		installPackage VideoCodecs
		installPackage GraphVisualization

		installPackage MIRACenter
		installPackage TapeEditor
		#installPackage TapeRecorder # since 2013-02-14 part of MIRACenter
		#installPackage TapePlayer   # since 2013-02-14 part of MIRACenter

		installPackage MIRA
		installPackage MIRAgui
		installPackage MIRAtape
		installPackage MIRAinspect
		installPackage MIRAWizard

		# Now delete the bootstrap directory
		rm -rf $BOOTSTRAP_DIR

		;;
	12)
		#######################################################################
		# Build MIRA

		cd $INSTALL_DIR
		export MIRA_PATH="$INSTALL_DIR"

		infoMsg "INFO: Building MIRA 1/3: Perform the cmake step..."
		make depend_$TARGET >> $LOG_FILE 2>&1
		if [ $PIPESTATUS -ne 0 ] ; then
			fatalInfoMsg "FATAL: cmake step failed."
		fi

		infoMsg "INFO: Building MIRA 2/3: Building MIRABase..."
		make MIRABase_$TARGET 2>&1 | tee -a $LOG_FILE | \
			grep --line-buffered "%]" | awk '{printf("\b\b\b\b\b\b\b%6s",substr($0,0,6))}'
		if [ $PIPESTATUS -ne 0 ] ; then
			fatalInfoMsg "FATAL: Building MIRABase failed."
		fi
		echo ""

		infoMsg "INFO: Building MIRA 3/3: Compiling. Please wait (~45min, Dual-core 2GHz)..."
		make -j$JOB_CNT $TARGET 2>&1 | tee -a $LOG_FILE | \
			grep --line-buffered "%]" | awk '{printf("\b\b\b\b\b\b\b%6s",substr($0,0,6))}'
		if [ $PIPESTATUS -ne 0 ] ; then
			fatalInfoMsg "FATAL: Building MIRA failed."
		fi
		echo "";;
	13)
		#######################################################################
		# Create bash file

		START_BASH=$INSTALL_DIR/start.bash
		touch $START_BASH
		echo "export MIRA_PATH=$INSTALL_DIR" >> $START_BASH
		echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$INSTALL_DIR/lib" >> $START_BASH
		echo "export PATH=\$PATH:$INSTALL_DIR/bin" >> $START_BASH
		echo "source $INSTALL_DIR/scripts/mirabash" >> $START_BASH;;
	esac
	# Write current completed stage to stage file
	expr $i + 1 > $STAGE_FILE
done

# clean up
rm $STAGE_FILE

infoMsg "************************************************************************"
infoMsg "*"
infoMsg "* Installation and compilation of MIRA is finished."
infoMsg "* Please add the following environment variables to your configuration:"
infoMsg "*    export MIRA_PATH=$INSTALL_DIR"
infoMsg "*    export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$INSTALL_DIR/lib"
infoMsg "*    export PATH=\$PATH:$INSTALL_DIR/bin       (this is optional)"
infoMsg "*    source $INSTALL_DIR/scripts/mirabash"
infoMsg "* or use"
infoMsg "*    source $START_BASH"
infoMsg "* in your bash console to get started"
infoMsg "************************************************************************"
infoMsg ""

#if confirm "Start mirapackage to install more packages" ; then
#	export MIRA_PATH="$INSTALL_DIR"
#	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$INSTALL_DIR/lib
#	$INSTALL_DIR/bin/mirapackage
#fi
