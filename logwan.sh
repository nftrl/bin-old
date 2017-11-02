#!/bin/bash
# Log WAN and LAN ip addresses to file ip.log

# Create log file ip.log if it doesn't exist.
if [ ! -f 'ip.log' ]
then
	touch ip.log
fi

DATE="$(date)"
LAN="$(ifconfig wlp2s0 | nl | grep -E " 2" | grep -oE "(addr:.* B)" | grep -oE "([0-9]\.?)*")"
WAN="$(dig +short myip.opendns.com @resolver1.opendns.com)"
WANRETVAL="$?"

# If WANRETVAL != 0 it probably means that there is no internet connection.
# Abandon ship with exit status WANRETVAL.
if [ "$WANRETVAL" -ne 0 ]
then
	exit "$WANRETVAL"
fi

# If all is good, append to log file.
printf "DATE\t%b\nWAN \t%b\nLAN \t%b\n\n" "$DATE" "$WAN" "$LAN" >> ip.log
exit 0
