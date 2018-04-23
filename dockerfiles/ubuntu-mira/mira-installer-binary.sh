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
echo "* This is the MIRA binary installer. It will download and compile a"
echo "* basic configuration of MIRA on your system."
echo "*"
echo "************************************************************************"
echo ""

FTPURL=ftp://mira-project.org

if [ $# -gt 2 -o $# -eq 0 -o "$1" == "help" -o "$1" == "--help" ] ; then
	echo "Usage: $0 SystemName [ftp url]"
	echo "  Following systems are supports at default FTP (\"$FTPURL\"): "
	echo "    redhat-el6-i686     : RedHat Enterprise Linux / CentOS 6.x, 32bit"
	echo "    redhat-el7-x64      : RedHat Enterprise Linux / CentOS 7.x, 64bit"
	echo "    ubuntu-1204lts-i686 : Ubuntu 12.04LTS, 32bit"
	echo "    ubuntu-1204lts-x64  : Ubuntu 12.04LTS, 64bit"
	echo "    ubuntu-1404lts-x64  : Ubuntu 14.04LTS, 64bit"
	echo "    ubuntu-1604lts-x64  : Ubuntu 16.04LTS, 64bit"
	exit
fi

SYSTEM=$1

if [ $# -gt 1 ] ; then
	echo "The following FTP settings will be used:"
	FTPURL=$2
	echo "Url: ${FTPURL}"
	if ! confirm "Do you want to proceed?"  ; then
		exit
	fi
fi

###############################################################################

INSTALL_DIR_DEFAULT=`pwd`/mira

read -p "Please input the installation directory. Enter=default($INSTALL_DIR_DEFAULT): " INSTALL_DIR_INPUT

if [ -z "$INSTALL_DIR_INPUT" ]; then
	INSTALL_DIR_INPUT=$INSTALL_DIR_DEFAULT
fi

# normalize the path
INSTALL_DIR=$(cd $(eval "dirname ${INSTALL_DIR_INPUT}");pwd)/$(eval "basename ${INSTALL_DIR_INPUT}")

#######################################################################
# Variables

BOOTSTRAP_DIR=$INSTALL_DIR/bootstrap

DOWNLOAD_DIR=$INSTALL_DIR
LOG_FILE="$INSTALL_DIR/install.log"
STAGE_FILE="$INSTALL_DIR/install.stage"
START_STAGE=1
END_STAGE=12

MIRAENV_URL="${FTPURL}/repos/MIRA-main/${SYSTEM}/env/latest/MIRA-MIRAenvironment*.zip"
MIRAEXT_URL="${FTPURL}/repos/MIRA-main/${SYSTEM}/external/latest/MIRA-external*.zip"
MIRABASE_URL="${FTPURL}/repos/MIRA-main/${SYSTEM}/base/latest/MIRA-MIRABase*.zip"
MIRAPACKAGE_URL="${FTPURL}/repos/MIRA-main/${SYSTEM}/tools/mirapackage/latest/MIRA-MIRAPackage*.zip"

#######################################################################

# check if the directory already exists
if [ -d $INSTALL_DIR ] ; then
	#exists check for install.stage file
	if [ -e $STAGE_FILE ] ; then
		# stage file exists retrieve last stage
		read -r LAST_STAGE < $STAGE_FILE
		if [ -n $LAST_STAGE ] ; then
			echo ""
			if confirm "The Directory $INSTALL_DIR already exists and contains a previously started installation. Continue this installation?" ; then 
				START_STAGE=$LAST_STAGE
			else
				rm -rf $INSTALL_DIR
			fi
		else
			echo ""
			if confirm "Directory $INSTALL_DIR already exists. All data in that directory will be lost! Continue?" ; then
				echo "Removing old directory content..."
				rm -rf $INSTALL_DIR
			else
 				exit
			fi
		fi
	else
		echo ""
		if confirm "Directory $INSTALL_DIR already exists. All data in that directory will be lost! Continue?" ; then
			echo "Removing old directory content..."
			rm -rf $INSTALL_DIR
		else
 			exit
		fi
	fi
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
		# Download MIRAEnvironment

		infoMsg "INFO: Downloading MIRAEnvironment..."
		wget -q $MIRAENV_URL -P $DOWNLOAD_DIR
		if [ $? -ne 0 ] ; then
			fatalInfoMsg "FATAL: Failed to download $MIRAENV_URL"
		fi;;
	3)
		#######################################################################
		# Download MIRA external

		infoMsg "INFO: Downloading MIRA external..."
		wget -q $MIRAEXT_URL -P $DOWNLOAD_DIR
		if [ $? -ne 0 ] ; then
			fatalInfoMsg "FATAL: Failed to download $MIRAEXT_URL"
		fi;;
	4)
		#######################################################################
		# Download MIRABase

		infoMsg "INFO: Downloading MIRABase..."
		wget -q $MIRABASE_URL -P $DOWNLOAD_DIR
		if [ $? -ne 0 ] ; then
			fatalInfoMsg "FATAL: Failed to download $MIRABASE_URL"
		fi;;
	5)
		#######################################################################
		# Download MIRAPackage

		infoMsg "INFO: Downloading MIRAPackage..."
		wget -q $MIRAPACKAGE_URL -P $DOWNLOAD_DIR
		if [ $? -ne 0 ] ; then
			fatalInfoMsg "FATAL: Failed to download $MIRAPACKAGE_URL"
		fi;;
	6)
		#######################################################################
		# Create the MIRA bootstrap environment
		
		infoMsg "INFO: Unzip MIRAenvironment..."
		# unzip MIRAenvironment
		cd $BOOTSTRAP_DIR
		unzip -q $DOWNLOAD_DIR/MIRA-MIRAenvironment*.zip

		# Clean up
		rm $DOWNLOAD_DIR/MIRA-MIRAenvironment*.zip;;
	7)
		#######################################################################
		# Unpack MIRA external in bootstrap environment
		
		infoMsg "INFO: Unzip MIRA external..."
		# unzip MIRABase
		cd $BOOTSTRAP_DIR
		unzip -q $DOWNLOAD_DIR/MIRA-external*.zip

		# Clean up
		rm $DOWNLOAD_DIR/MIRA-external*.zip;;
	8)
		#######################################################################
		# Unpack MIRABase in bootstrap environment

		infoMsg "INFO: Unzip MIRABase..."
		# unzip MIRABase
		cd $BOOTSTRAP_DIR
		unzip -q $DOWNLOAD_DIR/MIRA-MIRABase*.zip

		# Clean up
		rm $DOWNLOAD_DIR/MIRA-MIRABase*.zip;;
	9)
		#######################################################################
		# Unpack MIRAPackage in bootstrap environment

		infoMsg "INFO: Unzip MIRAPackage..."
		# unzip MIRAPackage
		cd $BOOTSTRAP_DIR/tools
		unzip -q $DOWNLOAD_DIR/MIRA-MIRAPackage*.zip

		# Clean up
		rm $DOWNLOAD_DIR/MIRA-MIRAPackage*.zip;;
	10)
		#######################################################################
		# Fixing directory names

		infoMsg "INFO: Fixing directory names in MIRA base system."
		cd $BOOTSTRAP_DIR

		for p in `find . -type d -a -name "MIRA_*"`; do
			b=`basename $p`
			newDir=${b/MIRA_/}
			if [ ! -d $newDir ] ; then mkdir $newDir ; fi
			mv $p/* $newDir
			rmdir $p
		done

		# Delete package files in BOOTSTRAP directory to avoid the mirapackage
		# will find them.
		find $BOOTSTRAP_DIR -name "*.package" | xargs rm -f

		;;
	11)
		#######################################################################
		# Use mirapackage to download and install the rest of MIRA

		cd $BOOTSTRAP_DIR
		export MIRA_PATH="$BOOTSTRAP_DIR:$INSTALL_DIR"
		export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$BOOTSTRAP_DIR/lib"

		if [ -f ${HOME}/.config/mira/mirapackage.xml ] ; then
			if confirm "An existing configuration of mirapackage was found. Should the installer delete this to get a clean environment" ; then
				infoMsg "INFO: Clear repositories."
				$BOOTSTRAP_DIR/bin/mirapackage --clearrepos 2>&1 | tee -a $LOG_FILE
			fi
		fi

		# Ignore error here, which may caused by invalid repo configuration
		#if [ $PIPESTATUS -ne 0 ] ; then
		#	fatalInfoMsg "FATAL: Clear repositories failed."
		#fi

		infoMsg "INFO: Add installation repository"
		$BOOTSTRAP_DIR/bin/mirapackage --addurl "${FTPURL}/repos/MIRA-main/${SYSTEM}/MIRA-main.repo" 2>&1 | tee -a $LOG_FILE
		if [ $PIPESTATUS -ne 0 ] ; then
			fatalInfoMsg "FATAL: Add installation repository failed."
		fi

		infoMsg "INFO: Reindex installation repository"
		$BOOTSTRAP_DIR/bin/mirapackage --reindex 2>&1 | tee -a $LOG_FILE
		if [ $PIPESTATUS -ne 0 ] ; then
			fatalInfoMsg "FATAL: Reindex installation repository failed."
		fi

		installPackage MIRAenvironment
		installPackage external
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

if confirm "Start mirapackage to install more packages" ; then
	export MIRA_PATH="$INSTALL_DIR"
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$INSTALL_DIR/lib
	$INSTALL_DIR/bin/mirapackage
fi
