#!/bin/bash
#User nagios executes the megacli binary, add this to your /etc/sudoers file
#nagios ALL=NOPASSWD:/opt/MegaRAID/MegaCli/MegaCli64

megacli="sudo /opt/MegaRAID/MegaCli/MegaCli64"
temp_warning=50
temp_critical=60

if [ $1 == slots ]
then
        $megacli -PDList -aALL | grep -e "^Slot Number: "
        exit 0
elif [ $1 == temp ]
then
        output=$($megacli PDInfo -PhysDrv [64:$2] -aAll | grep -e '^Drive Temperature')
        temp=$(echo $output | grep -o '...\C' | tr -d ':'| tr -d 'C')
        cat "$file1" | grep -o '...\C' | tr -d ':'| tr -d 'C' &>> $file2
        if [ "$temp" -gt "$temp_warning" ]
        then
                nagioscode=1
        elif [ "$temp" -gt "$temp_critical" ]
        then
                nagioscode=2
        elif [ "$temp" -lt "$temp_warning" ]
        then
                nagioscode=0
        else
                nagioscode=3
        fi
        output=$(echo $output | grep -o '...\C' | tr -d ':')
        echo "Drive $2: $output"
        exit $nagioscode
elif [ $1 == type ]
then
        output=$($megacli PDInfo -PhysDrv [64:$2] -aAll | grep -e '^Inquiry Data:')
        output=$(echo $output | tr -d '^Inquiry Data:')
        echo "Drive $2: $output"
fi
