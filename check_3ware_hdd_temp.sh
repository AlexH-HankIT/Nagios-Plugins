#!/bin/bash
#
# Author: MrCrankHank
#
#
# User nagios needs permission to execute the tw-cli binary. Add this to your /etc/sudoers:
# nagios ALL=NOPASSWD: /usr/sbin/tw-cli
#

CLI=`which tw-cli`
sudo=`which sudo`
CONTROLLER=$1
HDD=$2
WARN=$3
CRIT=$4

function usage() {
        echo "./check_3ware_hdd_temp <controller> <disk> <warn> <crit>"
        exit 1
}

if [[ -z $1 || -z $2 || -z $3 || -z $4 ]]; then
        usage
fi

TEMP=$($sudo $CLI /c$CONTROLLER/p$HDD show temperature | grep -o '[0-9]\{2\}')

if [ $TEMP -lt $WARN ]; then
        echo "OK - Temperature of drive $HDD is ${TEMP}C"
        exit 0
elif [ $TEMP -gt $CRIT ]; then
        echo "CRITICAL - Temperature of drive $HDD is ${TEMP}C"
        exit 2
elif [ $TEMP -ge $WARN ]; then
        echo "WARNING - Temperature of drive $HDD is ${TEMP}C"
        exit 1
else
        echo "UNKNOWN - Temperature is unknown"
        exit 3
fi
