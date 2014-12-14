#!/bin/bash
#
#
# Author: MrCrankHank
#

function usage() {
        echo "./check_fetchmail.sh <LOG_FILE>"
        echo
        echo "LOG_FILE This parameter allows to specify a path to the fetchmail.log file. Default is /var/log/fetchmail/fetchmail.log"
        echo
        echo "  The script will check the last 10 lines of the fetchmail log file for errors like \"DNS\" or \"AUTHFAIL\""
        echo
        echo " Installation"
        echo "  1. Fetchmail must log to a dedicated file not syslog. Use something like this in your /etc/fetchmailrc:"
        echo "          set no syslog"
        echo "          set logfile /var/log/fetchmail/fetchmail.log"
        echo
        echo "  2. Create the dir /var/log/fetchmail and change the permissions:"
        echo "          chown fetchmail:nagios /var/log/fetchmail"
        echo
        echo "  3. Create a config for logrotation:"
        echo "          /etc/logrotate.d/fetchmail"
        echo "          /var/log/fetchmail.log {"
        echo "          weekly"
        echo "          create 0644 fetchmail nagios"
        echo "          rotate 4"
        echo "          compress"
        echo "          delaycompress"
        echo "          }"
        exit 1
}

# Last lines of the log file to check for errors
LINES=10

# Check if the log file is there
if ! [ -z $1 ]; then
        LOG=$1
else
        LOG=/var/log/fetchmail/fetchmail.log
fi

if ! [ -f $LOG ]; then
        echo "Unknown - could not open the file fetchmail.log"
        echo
        usage
        exit 3
fi

# Check for auth errors
AUTH=$(tail -$LINES $LOG | grep -c "AUTHFAIL")
DNS=$(tail -$LINES $LOG | grep -c "DNS")

# Perform the actually check
if ! [[ $AUTH == 0 && $DNS == 0 ]]; then
        echo "Critical - Fetchmail could not fetch mails for at least one user"
        exit 2
else
        echo "OK - No errors detected"
        exit 0
fi
