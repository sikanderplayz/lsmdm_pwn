# -------------------------------------------------------------------------------------------------------- #
#                                        LSMDM_pwn, by August712                                           #
#                       A script to remove MDM services on a jailed iOS device.                            #
#                       Tested with OS X 10.11.4, Xcode 7.3, iOS 9.2.1/9.3/9.3.1.                          #
#              Thanks to: defying (for the script style) and qwertyoruiop (for compiling mdbdtool)         #
# -------------------------------------------------------------------------------------------------------- #

#!/bin/bash

# Initial Vars #

COMMAND=$1
IOSDEPLOY="./bin/ios-deploy"
LIBIMOBILEDEVICE="./bin/idevicename"
MDBDTOOL="./bin/mdbdtool"
WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TMP_DIR=".temp"
DEV_CERT_NAME="iPhone Developer"
CODESIGN_NAME=`security dump-keychain login.keychain|grep "$DEV_CERT_NAME"|head -n1|cut -f4 -d \"|cut -f1 -d\"`
SUFFIX="-"$(uuidgen)
LOGFILE=tweakpatcher.log
BACKUP="backup"
BINDIR="/bin"

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

 Syntax: ./lsmdm_pwn [pwn|usage]
USAGE
 	fi
}

function agreement {
  read -p "[⛔️  ] By using LSMDM_pwn you hereby agree that I, Andrew 'August712' Augustine, will not be held responsible for any of the outcomes of you using it. In most cases, Companies / Schools have MDM on their devices so that they monitor the use of their tools and networks. If you are using this program, make sure that this device is your own, not your workplaces / schools. (Read the Acceptable Use Policy for that one, bud.)

  Also, at this point, if you understand, Make sure you have a working version of Xcode 7.0+ on your mac. Go ahead and turn Find my iPhone/iPad off, alongside your passcode. These are all neccecary requirements for this tool to work.

  [Press 'Enter' to continue, or click dat 'X' to cancel]"
}

function getDependencies {
	echo "[💯 ] Checking for required dependencies..." | tee -a $LOGFILE

  mkdir -p bin/

	if [ ! -f $LIBIMOBILEDEVICE ] || [ ! -f $IOSDEPLOY ] || [ ! -f $MDBDTOOL ]; then
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
        mv $TMP_DIR/libimobiledevice/afcclient $BIN/afcclient
        mv $TMP_DIR/libimobiledevice/fetchsymbols $BIN/fetchsymbols
        mv $TMP_DIR/libimobiledevice/idevicebackup2 $BIN/idevicebackup2
        mv $TMP_DIR/libimobiledevice/idevicediagnostics $BIN/idevicediagnostics
        mv $TMP_DIR/libimobiledevice/ideviceimagemounter $BIN/ideviceimagemounter
        mv $TMP_DIR/libimobiledevice/ideviceinfo $BIN/ideviceinfo
        mv $TMP_DIR/libimobiledevice/idevicename $BIN/idevicename
        mv $TMP_DIR/libimobiledevice/jtool $BIN/jtool
        mv $TMP_DIR/libimobiledevice/mobiledevice $BIN/mobiledevice
	  		cd $WORK_DIR
	      echo "[👍 ] done: libimobiledevice" | tee -a $LOGFILE
	  fi
    if [ ! -f $MDBDTOOL ]; then
	      echo "[📥 ] mdbdtool not found, downloading..." | tee -a $LOGFILE
	      cd $TMP_DIR
	  		curl -L https://github.com/August712/lsmdm_pwn/raw/master/mbdbtool.zip -o mdbdtool.zip >> $LOGFILE 2>&1
	      echo "[📦 ] extract: mdbdtool" | tee -a $LOGFILE
	  		unzip mdbdtool.zip >> $LOGFILE 2>&1
	  		rm mdbdtool.zip
        mv $TMP_DIR/mbdbtool/libcrippy-1.0.0.dylib $BIN/libcrippy-1.0.0.dylib
        mv $TMP_DIR/mbdbtool/libcrypto.1.0.0.dylib $BIN/libcrypto.1.0.0.dylib
        mv $TMP_DIR/mbdbtool/libimobiledevice.6.dylib $BIN/libimobiledevice.6.dylib
        mv $TMP_DIR/mbdbtool/libmbdb-1.0.0.dylib $BIN/libmbdb-1.0.0.dylib
        mv $TMP_DIR/mbdbtool/libplist.3.dylib $BIN/libplist.3.dylib
        mv $TMP_DIR/mbdbtool/libssl.1.0.0.dylib $BIN/libssl.1.0.0.dylib
        mv $TMP_DIR/mbdbtool/libusbmuxd.4.dylib $BIN/libusbmuxd.4.dylib
        mv $TMP_DIR/mbdbtool/libxml2.2.dylib $BIN/libxml2.2.dylib
        mv $TMP_DIR/mbdbtool/mbdbtool $BIN/mbdbtool
	  		cd $WORK_DIR
	      echo "[👍 ] done: mdbdtool" | tee -a $LOGFILE
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
    echo "[📲 ] Checking ideviceinfo..." | tee -a $LOGFILE
    $WORK_DIR/bin/ideviceinfo | grep UniqueDeviceID | tee -a $LOGFILE
    $WORK_DIR/bin/ideviceinfo | grep BuildVersion | tee -a $LOGFILE
    $WORK_DIR/bin/ideviceinfo | grep DeviceName | tee -a $LOGFILE
		echo ""
	fi
}

function backupWarning {
  echo "[⛔️ ] Please disable Find My iPhone and your passcode. We are not responisible for any damage done to your iDevice."
  read -p "[⛔️ ] When this has been done, press 'Enter' to continue."
  cd $WORK_DIR
  mkdir -p $BACKUP

  echo "[📲 ] Backing up, could take several minutes..."
  $WORK_DIR/bin/idevicebackup2 backup $BACKUP
  udid="$(ls tmp | head -1)"
}

function editFiles {
  echo "[💻 ] Editing files..."
  $WORK_DIR/bin/mbdbtool backup $udid HomeDomain rmdir --ignore-fail-on-non-empty Library/ConfigurationProfiles
  $WORK_DIR/bin/mbdbtool backup $udid HomeDomain curl -L https://github.com/August712/lsmdm_pwn/raw/master/UserConfigurationProfiles.zip -o Library/UserConfigurationProfiles.zip
  $WORK_DIR/bin/mbdbtool backup $udid HomeDomain unzip Library/UserConfigurationProfiles.zip
  $WORK_DIR/bin/mbdbtool backup $udid HomeDomain rm Library/UserConfigurationProfiles.zip
  echo "[👍 ] ...Done!"
}

function restoreFromBackup {
  echo "[📲 ] Restoring from modified backup..."
  $WORK_DIR/bin/idevicebackup2 restore --settings --reboot >> $LOGFILE 2>&1
  echo "[👍 ] Done! Waiting for reboot..."
  echo "[📱 ] When reboot is done, unlock your phone. (Don't worry! Your data's still there!)"
  read -p "[... ] When unlocked, press 'Enter' to continue."
}

function nowWeWait {
  echo "[📱 ] Sleeping for device to finish running the scripts..."
  echo "[📲 ] Reconnecting to phone..."
  $IOSDEPLOY -c -W  >> $LOGFILE 2>&1
	if [ "$?" != "0" ]; then
		echo "[❌ ] No iOS devices detected. Are you sure your device is plugged in?" | tee -a $LOGFILE
		exit 1
	else
		echo "[👍 ] Detected an iOS device... Again!" | tee -a $LOGFILE
		echo ""
	fi
  echo "[📲 ] Checking ideviceinfo..." | tee -a $LOGFILE
  $WORK_DIR/bin/ideviceinfo | grep UniqueDeviceID | tee -a $LOGFILE
  $WORK_DIR/bin/ideviceinfo | grep BuildVersion | tee -a $LOGFILE
  $WORK_DIR/bin/ideviceinfo | grep DeviceName | tee -a $LOGFILE
  echo " "
}

function wrapUp {
  echo "[🎉 ] LSMDM_pwn executed! Your device should be MDM free!" | tee -a $LOGFILE
  echo "[🔌 ] This tool was made by Andrew Augustine / @August712" | tee -a $LOGFILE
  echo "[💻 ] Twitter: http://twitter.com/August712/. Drop a like or a follow?" | tee -a $LOGFILE
  echo "[😀 ] Thanks for using the tool!" | tee -a $LOGFILE
}

case $1 in
	pwn)
    		agreement
		getDependencies
		detectDevice
    		backupWarning
    		editFiles
    		restoreFromBackup
    		nowWeWait
    		wrapUp
    		exit 1
	;;
	*)
		usage
		exit 1
	;;
esac
