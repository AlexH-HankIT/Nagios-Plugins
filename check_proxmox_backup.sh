#!/bin/bash
#
# Author: MrCrankHank
#

function usage() {
        echo "./check_proxmox_backup.sh <STORAGE> <VMID> <MAX_OLD_DAYS>"
        echo
        echo "STORAGE:  Name of your proxmox backup storage"
        echo "VMID:             VMID of the vm you want to check"
        echo "MAX_OLD_DAYS:     The script will trigger a critical alert if the backup is older then the days specified in this var."
        echo
        echo "The user nagios executes the pvesm binary via sudo. For this to work you have to modify your /etc/sudoers. E.g:"
        echo "  'nagios ALL=NOPASSWD: /usr/sbin/pvesm list *, /usr/bin/pvectl list *, /usr/bin/lxc-ls, /usr/sbin/qm list *'"
        echo
        exit 1
}

if [[ -z $1 || -z $2 || -z $3 ]]; then
        usage
fi

# binaries
PVESM="sudo /usr/sbin/pvesm"
PVECTL="sudo /usr/bin/pvectl"
LXCLS="sudo /usr/bin/lxc-ls"
QM="sudo /usr/sbin/qm"

# Temp file for pvesm output
LIST=/tmp/pvesmlist

# Name of your proxmox backup storage
BACKUP_STORAGE=$1

# vmid of the vm you want to check
ID=$2

# The script triggers an critical alert if the last backup is older than $MAX_OLD_DAYS days
MAX_OLD_DAYS=$3

# Check that vmid has at least 3 digits
len=$(echo ${#ID})
if [ $len -lt 3 ]; then
	echo "Critical - Invalid vmid"
	exit 2
fi

# Check for type
# Note: Proxmox dropt openvz support in 4.0
#KVM
if $QM list |grep $ID > /dev/null 2>&1 ; then
 TYPE="qemu"
else
 echo "Unknown - vm $ID does not exist"
 exit 3
fi
#OPENVZ
if [[ -f $PVECTL ]] ; then
 if $PVECTL list |grep $ID > /dev/null 2>&1 ; then
   TYPE="openvz"
 else
 echo "Unknown - vm $ID does not exist"
 exit 3
fi
fi
#LXC
if [[ -f $LXCLS ]] ; then
 if $LXCLS |grep $ID > /dev/null 2>&1 ; then
   TYPE="lxc"
 else
 echo "Unknown - vm $ID does not exist"
 exit 3
 fi
fi

# Check if backup storage exists
storageList=$($PVESM list $BACKUP_STORAGE 2>/dev/null);
if [ $? -ne 0 ]; then
	echo "Critical - Storage $BACKUP_STORAGE does not exist"
	exit 2
fi

echo "$storageList" | grep "vzdump-$TYPE-$ID" > $LIST
COUNT=$(wc -l < $LIST)

if [ $COUNT -eq 0 ]; then
        echo "Critical - No backups of vm $ID"
        exit 2
fi

line=$(cat $LIST | tail -1)

# local:backup/vzdump-openvz-104-2016_02_21-03_49_19.tar.lzo tar.lzo 33512905791
# nfs-backup:backup/vzdump-openvz-103-2016_02_20-03_34_45.tar.lzo tar.lzo 1962755572
[[ $line =~ \-$ID\-([0-9]{4})_([0-9]{2})_([0-9]{2})\-([0-9]{2})_([0-9]{2})_([0-9]{2}).*[[:space:]]([0-9]+)$ ]]
year=${BASH_REMATCH[1]}
month=${BASH_REMATCH[2]}
day=${BASH_REMATCH[3]}
hour=${BASH_REMATCH[4]}
minute=${BASH_REMATCH[5]}
second=${BASH_REMATCH[6]}
let "size=${BASH_REMATCH[7]} / 1024 / 1024"
#size=$(numfmt --grouping $size)

date="$month/$day/$year"
DATE_LOG=$(date +%m/%d/%y -d "$date + $MAX_OLD_DAYS day")
DATE_LOG_SEC=$(date -d $DATE_LOG '+%s')
TODAY=`date +%m/%d/%y`
TODAY=$(date -d "$TODAY" '+%s')

if [ -f $LIST ]; then
        rm $LIST
fi

if [[ $TODAY -ge $DATE_LOG_SEC ]]; then
        echo "Critical - $COUNT total backups of vm $ID. Last backup is from $date ${hour}:${minute}:${second}. Size: ${size}MB"
        exit 2
else
        echo "OK - $COUNT total backups of vm $ID. Last backup is from $date ${hour}:${minute}:${second}. Size: ${size}MB"
        exit 0
fi
