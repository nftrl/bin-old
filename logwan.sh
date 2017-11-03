#!/bin/bash

function printhelp {
	echo Usage: ./logwan.sh [--help] INTERFACE [LOGFILE]
	echo 
	echo Log WAN and LAN ip addresses. By default, print to stdout. If LOGFILE
	echo is given, instead append output to LOGFILE and do not print to stdout.
	echo Create LOGFILE if it doesn\'t exist.
}

# Read arguments
if [ "$#" -eq 0 ]
then
	printhelp
	exit 1
elif [[ "$1" == '--help' ]]
then
	printhelp
	exit 0
fi
INTERFACE="$1"
LOGFILE="$2"

function wanip {
	# Get WAN ip address and print to stdout.
	# First try with dig, then with curl.
	if command -v dig >/dev/null 2>&1
	then
		dig +short myip.opendns.com @resolver1.opendns.com
	elif command -v curl >/dev/null 2>&1
	then
		curl -s http://whatismyip.akamai.com/
	fi
}

# Get date, LAN ip address and WAN ip address.
DATE="$(date)"
ESSID="$(iwconfig "$INTERFACE" | grep -Eo "ESSID.*$" | grep -Eo "[\"].*[\"]" | grep -Eo "[^\"].*[^\"]")"
LAN="$(ifconfig "$INTERFACE" | nl | grep -E " 2" | grep -oE "(addr:.* B)" | grep -oE "([0-9]\.?)*")" || exit 2
WAN="$(wanip)" || exit 3

# Print output to stdout or LOGFILE
if [ -z "$LOGFILE" ]
then
	printf "DATE\t%b\nESSID\t%b\nWAN \t%b\nLAN \t%b\n\n" "$DATE" "$ESSID" "$WAN" "$LAN"
else
	# Create log file if it doesn't exist.
	if [ ! -f "$LOGFILE" ]; then touch "$LOGFILE"; fi
	printf "DATE\t%b\nESSID\t%b\nWAN \t%b\nLAN \t%b\n\n" "$DATE" "$ESSID" "$WAN" "$LAN" >> "$LOGFILE"
fi

exit 0
