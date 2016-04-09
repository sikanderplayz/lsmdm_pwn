#!/bin/bash

 # Initial Vars #

 COMMAND=$1
 TWEAK=$2
 IPA=$3
 MOBILEPROVISION=$4
 PATCHO="./bin/patcho"
 IOSDEPLOY="./bin/ios-deploy"
 OPTOOL="./bin/optool"
 WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
 TMP_DIR=".temp"
 DEV_CERT_NAME="iPhone Developer"
 CODESIGN_NAME=`security dump-keychain login.keychain|grep "$DEV_CERT_NAME"|head -n1|cut -f4 -d \"|cut -f1 -d\"`
 SUFFIX="-"$(uuidgen)
 LOGFILE=tweakpatcher.log

 declare -a ORIG_BUNDLE_ID

 cd $WORK_DIR
 rm -rf $TMP_DIR/
 mkdir -p $TMP_DIR/
 rm $LOGFILE >& /dev/null

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

 
