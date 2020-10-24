#!/usr/bin/env bash
# Jarosław Rymut, 2020
####################

if [[ "${BASH_VERSINFO}" -lt 4 ]]; then
	echo "Sorry, you need at least bash 4 to run this script." >&2
	exit 1
fi

if [[ ! -r ./functions ]]; then
	echo "Sorry, you need read permission to ./functions to run this script." >&2
	exit 1
fi

. ./functions

usage() {
	echo 'Help!'
	echo 'HELP!'
	echo
	echo 'Jarosław Rymut, 2020'
	exit 0
}

####################

verbose=0
quiet=0

height=9
width=9
mines=10

####################

while getopts -- ":-:hvqr:m:" opt; do
	case ${opt} in
		q ) quiet=1 ;;
		v ) verbose=1 ;;
		r ) RANDOM=$OPTARG ;;
		m ) mines=$OPTARG ;;
		\? ) invalid_option "-$OPTARG" ;;
		h ) usage ;;
		: ) echo "Invalid option: -$OPTARG requires an argument" 1>&2 ;;
		- ) # long variants
			case "$OPTARG" in
				help ) usage ;;
				quiet ) quiet=1 ;;
				verbose ) verbose=1 ;;
				*) invalid_option "--$OPTARG" ;;
			esac
			;;
	esac
done
shift $((OPTIND - 1))

if [[ $quiet -ne 0 ]]; then
	exec 9>&1 # save output
	# exec 1>&9 9>&- # restore stdout
	exec >/dev/null
fi

if [[ $verbose -eq 0 ]]; then
	exec 8<>/dev/null
else
	exec 8>&1
fi

####################

on_exit() {
	log "Restoring cursor on exit"
	printf '\033[?25h'
}
trap on_exit EXIT
log "Hiding cursor"
printf '\033[?25l'

####################

map=()
for i in $(seq 1 $mines); do
	log "Placing mine $i"
	place_mine
done

####################

# exec 3<>/dev/tcp/wttr.in/80
# echo -e "GET /?format=3 HTTP/1.1\r\nhost: wttr.in\r\nConnection: close\r\n\r\n" >&3
# cat <&3

log "Options: $@"
log "Verbose: $verbose"
log "Quiet: $quiet"

print_map
