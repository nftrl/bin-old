#!/bin/bash
# Søger dba.dk og printer resultater.

# Print help and exit if --help option or none at all is given
if [[ -z "$@" || "$1" = "--help" ]]
then
	echo "Usage: dba.sh [ARGUMENT]..."
	echo
	echo "Search dba.dk for each argument and print results."
	echo "With --help option: print this and exit."
	echo "By Marcus Larsen"
	exit 0
fi

# Iterate arguments
for ARG in "$@"
do
	echo "Search: $ARG"

	# Replace spaces with +
	SEARCH="${ARG// /+}"

	# Search dba.dk
	RESULTS="$(curl -s https://www.dba.dk/soeg/?soeg="$SEARCH" | grep --color=never "class=\"listingLink\"")"

	# Echo results if any
	if [[ ! -z "$RESULTS" ]]
	then
		echo $RESULTS
	else
		echo "None"
	fi
	echo
done

exit 0
