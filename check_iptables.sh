#!/bin/bash
#
#
# Author MrCrankHank
#

# Important bins
IPT=`which iptables`
IPSET=`which ipset`
SUDO=`which sudo`

if [ -z $1 ]; then
	echo "	Usage:"
	echo "	The nagios user needs the permission to list iptables and ipset rules. This is accomplished via sudo. Place this line inside your /etc/sudoers:"
	echo "	nagios ALL=NOPASSWD: /sbin/iptables -L -n, /sbin/iptables -t nat -L -n, /sbin/iptables -t mangle -L -n, /usr/sbin/ipset list *"
	echo
	echo
	echo "		IPTables:"
	echo "			./check_iptables iptables <table> <custom chains> <emptyok>"
	echo
	echo "			Possible values for <table> are 'filter', 'nat', 'mangle'"
	echo
	echo "			<custom chains> is the count of chains created in a table. They are added with iptables -N <chain>. The script will produce wrong output, if you specify a wrong count."
	echo "			For no custom chains use '0'"
	echo
	echo "			If there is a table that is normally empty, you have to specify the <emptyok> parameter. Otherwise the script will trigger a critical alert."
	echo
	echo "			Example:"
	echo "			./check_iptables iptables filter 0"
	echo
	echo "			Output:"
	echo "			OK - 20 rules in chain filter"
	echo
	echo "			Example:"
	echo "			./check_iptables iptables filter 0 emptyok"
	echo
	echo "			Output:"
	echo "			Critical - 20 rules in chain filter"
	echo
	echo "		IPSet:"
	echo "			./check_iptables ipset <ipset>"
	echo
	echo "			<ipset> is the name of the ipset you want to check. The script will trigger a critical alert if the set is empty"
	echo
	echo "			Example:"
	echo "			./check_iptables ipset blacklist"
	echo
	echo "			Output:"
	echo "			OK - 40563 ips in ipset blacklist"
	echo
	echo "			Example:"
	echo "			./check_iptables ipset blacklist"
	echo
	echo "			Output:"
	echo "			Critical - No ips in ipset blacklist"
fi

case $1 in
	iptables)
		case $2 in
			filter)
				COUNT_FILTER=$($SUDO $IPT -L -n | wc -l)

				IPT_FILTER_EMPTY=8
                                if ! [ -z $3 ]; then
                                        ((IPT_FILTER_EMPTY=${3}*3+$IPT_FILTER_EMPTY))
                                fi

				((RULES_FILTER=${COUNT_FILTER}-${IPT_FILTER_EMPTY}))

				if ! [ -z $4 ]; then
					if [ $4 == "emptyok" ]; then
						if [ $COUNT_FILTER -le $IPT_FILTER_EMPTY ]; then
							echo "OK - No rules in chain filter"
							exit 0
						else
							echo "Critical - $RULES_FILTER rules in chain filter"
							exit 2
						fi
					fi
				fi

				if [ $COUNT_FILTER -le $IPT_FILTER_EMPTY ]; then
					echo "Critical - No rules in chain filter"
					exit 2
				else
					echo "OK - $RULES_FILTER rules in chain filter"
					exit 0
				fi
			;;

			nat)
				COUNT_NAT=$($SUDO $IPT -t nat -L -n | wc -l)

				IPT_NAT_EMPTY=11
				if ! [ -z $3 ]; then
					((IPT_NAT_EMPTY=${3}*3+$IPT_NAT_EMPTY))
				fi

				((RULES_NAT=${COUNT_NAT}-${IPT_NAT_EMPTY}))

				if ! [ -z $4 ]; then
					if [ $4 == "emptyok" ]; then
						if [ $COUNT_NAT -le $IPT_NAT_EMPTY ]; then
							echo "OK - No rules in chain nat"
							exit 0
						else
							echo "Critical - $RULES_NAT rules in chain nat"
							exit 2
						fi
					fi
				fi

				if [ $COUNT_NAT -le $IPT_NAT_EMPTY ]; then
					echo "Critical - No rules in chain nat"
					exit 2
				else
					echo "OK - $RULES_NAT rules in chain nat"
					exit 0
				fi
			;;

			mangle)
				COUNT_MANGLE=$($SUDO $IPT -t mangle -L -n | wc -l)

				IPT_MANGLE_EMPTY=14
				if ! [ -z $3 ]; then
					((IPT_MANGLE_EMPTY=${3}*3+$IPT_MANGLE_EMPTY))
				fi

				((RULES_MANGLE=${COUNT_MANGLE}-${IPT_MANGLE_EMPTY}))

				if [ -z $4 ]; then
					if [ $4 == "emptyok" ]; then
						if [ $COUNT_MANGLE -le $IPT_MANGLE_EMPTY ]; then
							echo "OK - No rules in chain mangle"
							exit 0
						else
							echo "Critical - $RULES_MANGLE rules in chain mangle"
							exit 2
						fi
					fi
				fi

				if [ $COUNT_MANGLE -le $IPT_MANGLE_EMPTY ]; then
					echo "Critical - No rules in chain mangle"
					exit 2
				else
					echo "OK - $RULES_MANGLE rules in chain mangle"
					exit 0
				fi
			;;
		esac
	;;
	ipset)
		LIST=$2
		IPSET_EMPTY=6
		COUNT_IPSET=$($SUDO $IPSET list $LIST | wc -l)

		if [ $COUNT_IPSET -le $IPSET_EMPTY ]; then
			echo "Critical - No ips in ipset $LIST"
			exit 2
		else
			echo "OK - $COUNT_IPSET ips in ipset $LIST"
			exit 0
		fi
		;;
esac
