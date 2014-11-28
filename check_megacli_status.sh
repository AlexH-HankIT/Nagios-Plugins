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
megacli="/opt/MegaRAID/MegaCli/MegaCli64"
VD=$1
CONTROLLER=$2

function usage() {
        echo "./check_megacli_status.sh <virtualdrive> <controller>"
        exit 1
}

if [[ -z $1 || -z $2 ]]; then
        usage
fi

state=$(sudo $megacli -LDInfo -L$VD -a$CONTROLLER | grep -e "^State" | tr -d ':' | tr -d ' ' | sed -e 's/State//g')

if [ -z $state ]; then
        echo "Unknown - Could not get raid status on controller $CONTROLLER"
        exit 3
fi

if [ "$state" == "Optimal" ]; then
        echo "OK - Raid status is $state on controller $CONTROLLER"
        exit 0
else
        echo "CRITICAL - Raid status is $state on controller $CONTROLLER"
        exit 2
fi
