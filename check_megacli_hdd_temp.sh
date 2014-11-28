#!/bin/bash
#
# Author: MrCrankHank
#
#
# User nagios executes the megacli binary, add this to your /etc/sudoers file
# nagios ALL=NOPASSWD:/opt/MegaRAID/MegaCli/MegaCli64
#
#

# Path to your megacli binary
megacli='/opt/MegaRAID/MegaCli/MegaCli64'
HDD=$1
WARN=$2
CRIT=$3

function usage() {
        echo "./check_megacli_hdd_temp.sh <disk> <warn> <crit>"
        exit 1
}

if [[ -z $1 || -z $2 || -z $3 ]]; then
        usage
fi

TEMP=$(sudo $megacli PDInfo -PhysDrv [64:$HDD] -aAll | grep 'Drive Temperature' | grep -o '[0-9]\{2\}C' | tr -d 'C')
if [ $TEMP -lt $WARN ]; then
        echo "OK - Temperature is ${TEMP}C"
        exit 0
elif [ $TEMP -gt $CRIT ]; then
        echo "CRITICAL - Temperature is ${TEMP}C"
        exit 2
elif [ $TEMP -ge $WARN ]; then
        echo "WARNING - Temperature is ${TEMP}C"
        exit 1
else
        echo "UNKNOWN - Temperature is unknown"
        exit 3
fi
