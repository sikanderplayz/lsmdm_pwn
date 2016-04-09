#!/bin/bash

 # Initial Vars #

IOSDEPLOY="./bin/ios-deploy"
LIBIMOBILEDEVICE="./bin/idevicename"
WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TMP_DIR=".temp"
DEV_CERT_NAME="iPhone Developer"
CODESIGN_NAME=`security dump-keychain login.keychain|grep "$DEV_CERT_NAME"|head -n1|cut -f4 -d \"|cut -f1 -d\"`
SUFFIX="-"$(uuidgen)
LOGFILE=tweakpatcher.log
BACKUP="backup"

# Other stuff #

declare -a ORIG_BUNDLE_ID

cd $WORK_DIR
rm -rf $TMP_DIR/
mkdir -p $TMP_DIR/
rm $LOGFILE >& /dev/null

# Actual Script #

echo "[👻 ] lsmdm_pwn for jailed iOS devices v1.0b1" | tee -a $LOGFILE
echo "[🔌 ] by Andrew Augustine / @August712" | tee -a $LOGFILE
echo "[💻 ] GitHub: https://github.com/August712/lsmdm_pwn" | tee -a $LOGFILE
echo ""

if xcodebuild -version | grep -q "Xcode 7"; then
    echo "[💻 ] Xcode 7+ detected." | tee -a $LOGFILE
    echo ""
else
   echo "[❌ ] Outdated version of Xcode detected. This script requires Xcode 7+." | tee -a $LOGFILE
	 echo "Download Xcode from the Mac App Store." | tee -a $LOGFILE
	 exit 1
fi

function usage {
 if [ "$2" == "" -o "$1" == "" ]; then
 		cat <<USAGE

 Syntax: ./lsmdm_pwn
USAGE
 	fi
}

function getDependencies {
	echo "[💯 ] Checking for required dependencies..." | tee -a $LOGFILE

  mkdir -p bin/

	if [ ! -f $LIBIMOBILEDEVICE ] || [ ! -f $IOSDEPLOY ]; then
    pwd >> $LOGFILE 2>&1
		if [ ! -f $IOSDEPLOY ]; then
	      echo "[📥 ] ios-deploy not found, downloading..." | tee -a $LOGFILE
	      cd $TMP_DIR
	  		curl -L https://github.com/phonegap/ios-deploy/archive/1.8.5.zip -o ios-deploy.zip >> $LOGFILE 2>&1
	      echo "[📦 ] extract: ios-deploy" | tee -a $LOGFILE
	  		unzip ios-deploy.zip >> $LOGFILE 2>&1
	  		rm ios-deploy.zip
	  		cd ios-deploy-*
	      echo "[🔨 ] build: ios-deploy" | tee -a $LOGFILE
	  		xcodebuild >> $LOGFILE 2>&1
				if [ "$?" != "0" ]; then
					echo ""
					echo "[⚠️ ] Failed to build ios-deploy" | tee -a $LOGFILE
					exit 1
				fi
	  		cd $WORK_DIR
	  		mv $TMP_DIR/ios-deploy-*/build/Release/ios-deploy $IOSDEPLOY
	      echo "[👍 ] done: ios-deploy" | tee -a $LOGFILE
	  fi
    pwd >> $LOGFILE 2>&1
		if [ ! -f $LIBIMOBILEDEVICE ]; then
	      echo "[📥 ] libimobiledevice not found, downloading..." | tee -a $LOGFILE
	      cd $TMP_DIR
	  		curl -L https://github.com/August712/lsmdm_pwn/raw/master/libimobiledevice.zip -o libimobiledevice.zip >> $LOGFILE 2>&1
	      echo "[📦 ] extract: libimobiledevice" | tee -a $LOGFILE
	  		unzip libimobiledevice.zip >> $LOGFILE 2>&1
	  		rm libimobiledevice.zip
	  		cd $WORK_DIR
	      echo "[👍 ] done: libimobiledevice" | tee -a $LOGFILE
	  fi

    ## Other Binaries ##

		echo "[👍 ] All missing dependencies obtained." | tee -a $LOGFILE
		echo ""
	else
		echo "[👍 ] All dependencies found." | tee -a $LOGFILE
		echo ""
	fi
  rm -rf $TMP_DIR/*
}

function detectDevice {
	# detect attached iOS device
	echo "[📱 ] Waiting up to 5 seconds to detect an iOS device.." | tee -a $LOGFILE
	$IOSDEPLOY -c -W  >> $LOGFILE 2>&1
	if [ "$?" != "0" ]; then
		echo "[❌ ] No iOS devices detected. Are you sure your device is plugged in?" | tee -a $LOGFILE
		exit 1
	else
		echo "[👍 ] Detected an iOS device:" | tee -a $LOGFILE
    $WORK_DIR/bin/idevicename
		echo ""
	fi
}

function backupWarning {
  echo "[⛔️ ] Please disable Find My iPhone and your passcode. We are not responisible for any damage done to your iDevice."
  read -p "[⛔️ ] When this has been done, press 'Enter' to continue."
  cd $WORK_DIR
  mkdir -p $BACKUP

  #echo "[📱 ] Backing up, could take several minutes..."
  #$WORK_DIR/bin/idevicebackup2 backup $BACKUP
}

#function editingFiles {
#  echo "[💻 ] Editing files..."
#  cd $BACKUP/System\ files/HomeDomain/Library
#  rmdir --ignore-fail-on-non-empty ConfigurationProfiles
#}
