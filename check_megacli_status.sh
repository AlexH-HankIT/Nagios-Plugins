#!/bin/bash
#User nagios executes the megacli binary, add this to your /etc/sudoers file
#nagios ALL=NOPASSWD:/opt/MegaRAID/MegaCli/MegaCli64


megacli="sudo /opt/MegaRAID/MegaCli/MegaCli64"

name=$($megacli -LDInfo -L$1 -aALL | grep -e "^Name" | tr -d ':' | tr -d ' ' | sed -e 's/Name//g')
state=$($megacli -LDInfo -L$1 -aALL | grep -e "^State" | tr -d ':' | tr -d ' ' | sed -e 's/State//g')
size=$($megacli -LDInfo -L$1 -aALL | grep -e "^Size")

if [ "$state" == "Optimal" ]
then
	nagioscode=0
else
	nagioscode=2
fi

echo "${name}: $state"
exit $nagioscode
