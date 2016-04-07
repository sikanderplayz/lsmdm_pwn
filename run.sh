#!/bin/sh

### Initial vars ###

SCRIPTPATH=`dirname $0`
ddi="$(find /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport 2>/dev/null | grep "9.2/.*.dmg$" || echo './data/DeveloperDiskImage.dmg' | head -1)"

cd $SCRIPTPATH

### Functions ###

function abort() {
echo "Error. Exiting..." >&2
exit 254;
}

### Ddi mount function ###

function mount_ddi(){
echo "Mounting DDI..."
./bin/ideviceimagemounter "$ddi" >/dev/null || echo "Couldn't mount DDI. Not an issue if Xcode's running, an issue if it isn't."
}

### Device detection function ###

function wait_for_device() {
echo "Waiting for device..."
while ! (./bin/afcclient deviceinfo | grep -q FSTotalBytes); do sleep 5; done 2>/dev/null
}

### Actual Functions ###

stage0() {
echo "Please disable Find My iPhone. We are not responisible for any damage done to your iDevice."

# Waiting for device
wait_for_device

echo "Recreating temp directory..."
rm -rf tmp
mkdir tmp

#  Backup device data

echo "Backing up, could take several minutes... (Depends on how much data you have on your device.)" >&2
./bin/idevicebackup2 backup tmp || abort
udid="$(ls tmp | head -1)"

echo "Editing files..."

# Insert Editing Script Here #

# Restore modified backup
echo "Restoring modified backup..."
(
./bin/idevicebackup2 restore tmp --system --reboot || abort
)>/dev/null


# ZZZZZZ....
echo "Sleeping until device reboot..."
sleep 20

# Wait for device
wait_for_device
read -p "Press [Enter] key when your device finishes restoring."
echo

# Finishing Up

echo "Your Device with ID:"
$SCRIPTPATH./bin/ideviceinfo | grep UniqueDeviceID | awk '{ print $2}'
echo "was successfully pwned!"
echo "Waiting for scripts to finish up..."
sleep 10
echo "Ready for use! You can unplug your device."
echo "Your device should now be 0wned!"
}

# Let's do this!
stage0 || abort

exit 0