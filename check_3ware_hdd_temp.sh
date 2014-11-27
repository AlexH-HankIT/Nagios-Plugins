#!/bin/bash
#
# Author: MrCrankHank
#


CLI=`which tw-cli`
CONTROLLER=$1
HDD=$2
WARN=45
CRIT=50

function usage() {
        echo "./check_3ware_hdd_temp <controller> <disk> <warn> <crit>"
        exit 1
}

if [[ -z $1 || -z $2 || -z $3 || -z $4 ]]; then
        usage
fi

TEMP=$($CLI /c$CONTROLLER/p$HDD show temperature | grep -o '[0-9]\{2\}')

if [ $TEMP -lt $WARN ]; then
        echo "OK - Temperature is $TEMP"
        exit 0
elif [ $TEMP -gt $CRIT ]; then
        echo "CRITICAL - Temperature is $TEMP"
        exit 2
elif [ $TEMP -ge $WARN ]; then
        echo "WARNING - Temperature is $TEMP"
        exit 1
else
        echo "UNKNOWN - Temperature is unknown"
        exit 3
fi
