#!/usr/bin/env bash
# Jarosław Rymut, 2020
####################

if (( ${BASH_VERSINFO} < 4 )); then
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

while getopts -- ":-:hvqr:m:s:" opt; do
	case ${opt} in
		q) quiet=1 ;;
		v) verbose=1 ;;
		r) RANDOM=$OPTARG ;;
		m) mines=$OPTARG ;;
		s) width=$OPTARG; height=$OPTARG ;;
		\?) invalid_option "-$OPTARG" ;;
		h) usage ;;
		:) echo "Invalid option: -$OPTARG requires an argument" 1>&2 ;;
		-) # long variants
			case "$OPTARG" in
				help) usage ;;
				quiet) quiet=1 ;;
				verbose) verbose=1 ;;
				*) invalid_option "--$OPTARG" ;;
			esac
			;;
	esac
done
shift $((OPTIND - 1))

if (( $quiet != 0 )); then
	exec 9>&1 # save output
	# exec 1>&9 9>&- # restore stdout
	exec >/dev/null
fi

if (( $verbose == 0 )); then
	exec 8<>/dev/null
else
	exec 8>&1
fi

(( width = $(limit $width 2 99) ))
(( height = $(limit $height 2 99) ))
(( mines = $(limit $mines 1 $(($width * $height - 1))) ))

log "Size: ${width}x$height"
log "Mines: $mines"
log "Options: $@"
log "Verbose: $verbose"
log "Quiet: $quiet"

####################

on_exit() {
	log "Restoring cursor on exit"
	printf '\033[?25h'
	stty echo
}
trap on_exit EXIT
log "Hiding cursor"
printf '\033[?25l'
stty -echo

####################

declare -A map
declare -A revealed
for i in $(seq 1 $mines); do
	log "Placing mine $i"
	place_mine
done

####################

# exec 3<>/dev/tcp/wttr.in/80
# echo -e "GET /?format=3 HTTP/1.1\r\nhost: wttr.in\r\nConnection: close\r\n\r\n" >&3
# cat <&3

cursor_x=1
cursor_y=1

clear
print_map
printf "\e[s"
while read -rsN1 key
do
	# read other bits, with 2ms delay
	read -rsN1 -t 0.0001 k1
	read -rsN1 -t 0.0001 k2
	key+=${k1}${k2}

	case "$key" in
		$'\e[A'|$'\e0A') # up
			(( cursor_y > 1 )) || continue
			printf "\e[$((1 + ${cursor_y}));$((1 + 3 * ${cursor_x}))H \e[1C \e[1A\e[3D>\e[1C<"
			(( cursor_y-- ))
			;;
		$'\e[B'|$'\e0B') # down
			(( cursor_y < height )) || continue
			printf "\e[$((1 + ${cursor_y}));$((1 + 3 * ${cursor_x}))H \e[1C \e[1B\e[3D>\e[1C<"
			(( cursor_y++ ))
			;;
		$'\e[C'|$'\e0C') # right
			(( cursor_x < width )) || continue
			printf "\e[$((1 + ${cursor_y}));$((1 + 3 * ${cursor_x}))H \e[1C >\e[1C<"
			(( cursor_x++ ))
			;;
		$'\e[D'|$'\e0D') # left
			(( cursor_x > 1 )) || continue
			printf "\e[$((1 + ${cursor_y}));$((1 + 3 * ${cursor_x}))H \e[1C \e[6D>\e[1C<"
			(( cursor_x-- ))
			;;
		' ') # space
			revealed[$(index $cursor_x $cursor_y)]=1
			clear
			print_map
			;;
		'q'|$'\n'|$'\e') # q, enter
			printf "\e[u"
			echo "Goodbye!"
			exit 0
			;;
	esac
done
printf "\e[u"
