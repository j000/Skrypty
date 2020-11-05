#!/usr/bin/env bash
# Jarosław Rymut, 2020
####################
# vim: ft=sh:ts=4:sw=4:tw=80:noet

if (( ${BASH_VERSINFO-5} < 4 )); then
	echo "Do działania wymagany jest Bash w wersji 4 lub wyższej" >&2
	exit 1
fi

usage() {
	cat <<EOT
Saper

Gra polega na odkrywaniu na planszy poszczególnych pól w taki sposób,
aby nie natrafić na minę. Na każdym z odkrytych pól napisana jest liczba min,
które bezpośrednio stykają się z danym polem (od zera do ośmiu). Jeśli
oznaczymy dane pole flagą, jest ono zabezpieczone przed odsłonięciem,
dzięki czemu przez przypadek nie odsłonimy miny.

Obsługa:
	ESC, q: wyjście
	Enter, f: flaga
	Spacja: odsłonięcie

Obsługiwane argumenty:
	-h, --help	wyświetl tą pomoc i wyjdź
	-s INT		ustawia rozmiar planszy
	-m INT		ustawia ilość min

Jarosław Rymut, 2020
EOT
}

invalid_option() {
	echo "Niepoprawny argument: $1"
	echo
	usage
	exit 1
}

####################

random() {
	if (( $# == 0 )); then
		echo $RANDOM
		return
	fi

	local -n tmp=$1

	(( cutoff = 32767 - 32767 % $2 ))
	while
		tmp=$RANDOM
		(( tmp >= cutoff ))
	do :; done
	(( tmp = tmp % $2 ))
	# echo $((tmp % $2))
}

max() {
	(( $# != 2 )) && return 1
	echo "$(( $1 > $2 ? $1 : $2 ))"
}

min() {
	(( $# != 2 )) && return 1
	echo "$(( $1 < $2 ? $1 : $2 ))"
}

limit() {
	(( $# != 3 )) && return 1
	echo "$(min $(max $1 $2) $3)"
}

log() {
	echo "$*" >&8
}

####################

restore_cursor() {
	echo -en '\e[u'
}

place_mine() {
	if (( $# == 2 )); then
		(( ${map[$1.$2]:=0} == -1 )) && return
	else
		while
			random x $width
			random y $height
			(( ${map[$x.$y]:=0} == -1 ))
		do :; done
	fi

	log "Mine is on $x $y"
	(( map[$x.$y] = -1 ))

	for dy in -1 0 1; do
		for dx in -1 0 1; do
			if (( ( dx == 0 && dy == 0 ) ||
				( x == 0 && dx == -1 ) ||
				( x == width - 1 && dx == 1 ) ||
				( y == 0 && dy == -1 ) ||
				( y == height - 1 && dy == 1 ) ))
			then
				continue
			fi
			tmp=$(( x + dx )).$(( y + dy ))
			(( map[$tmp] == -1 )) && continue
			(( map[$tmp] += 1 ))
		done
	done
}

print_char() {
	(( $# != 2 )) && return 1
	ind=$1.$2
	case ${revealed[$ind]-0} in
		0)
		echo -en '\e[30;47m # \e[0m'
		return
		;;
	2)
		echo -en '\e[30;46m F \e[0m'
		return
	esac

	m=${map[$ind]-0}
	case $m in
		0) echo -en '   ';;
		-1) echo -en '\e[30;41m M \e[0m';;
		1) echo -en ' \e[34m1\e[0m ';;
		2) echo -en ' \e[32m2\e[0m ';;
		*) echo -en " \e[31m$m\e[0m ";;
	esac
}

print_map() {
	echo 'Miny: '$mines
	for y in $(seq 0 $((height - 1))); do
		echo -n ' '
		for x in $(seq 0 $((width - 1))); do
			print_char $x $y
		done
		echo
	done
	echo -ne '\e[s' # save cursor position
}

move_cursor() {
	(( $# != 2 )) && return
	echo -ne "\e[$(( height - $2 ))A\e[$(( 1 + 3 * $1 ))C"
}

redraw() {
	(( $# != 2 )) && return
	move_cursor $1 $2
	print_char $1 $2
	restore_cursor
}

print_cursor() {
	(( $# != 2 )) && return
	move_cursor $1 $2
	echo -ne '<\e[1C>'
	restore_cursor
}

reveal() {
	(( $# != 2 )) && return
	ind=$1.$2
	(( revealed[$ind] != 0 )) && return

	revealed[$ind]=1
	(( covered -= 1 ))
	redraw $1 $2
	if (( map[$ind] == -1 )); then
		echo "GAME OVER"
		exit 0
	fi

	if (( ${map[$ind]:=0} == 0 )); then
		for dy in -1 0 1; do
			for dx in -1 0 1; do
				if (( ( dx == dy ) ||
					( $1 == 0 && dx == -1 ) ||
					( $1 == width - 1 && dx == 1 ) ||
					( $2 == 0 && dy == -1 ) ||
					( $2 == height - 1 && dy == 1 ) ))
				then
					continue
				fi
				reveal $(($1 + dx)) $(($2 + dy))
			done
		done
	fi
}

flag() {
	(( $# != 2 )) && return
	ind=$1.$2
	if (( revealed[$ind] == 0 )); then
		revealed[$ind]=2
	elif (( revealed[$ind] == 2)); then
		revealed[$ind]=0
	fi
	redraw $1 $2
}


####################

debug=0

height=9
width=9
mines=10

####################

while getopts -- ":-:hdm:s:r:" opt; do
	case ${opt} in
		d) debug=1 ;;
		m) mines=$OPTARG ;;
		s) width=$OPTARG; height=$OPTARG ;;
		r) RANDOM=$OPTARG ;;
		\?) invalid_option "-$OPTARG" ;;
		h)
			usage
			exit 0
			;;
		:) invalid_option "-$OPTARG wymaga argumentu" ;;
		-) # long variants
			case "$OPTARG" in
				help)
					usage
					exit 0
					;;
				debug) debug=1 ;;
				*) invalid_option "--$OPTARG" ;;
			esac
			;;
	esac
done
shift $((OPTIND - 1))
(( $# != 0 )) && invalid_option "$*"

if (( debug == 0 )); then
	exec 8<>/dev/null
else
	exec 8>&1
fi

(( width = $(limit $width 2 99) ))
(( height = $(limit $height 2 99) ))
(( mines = $(limit $mines 1 $(($width * $height - 1))) ))

log "Size: ${width}x$height"
log "Mines: $mines"
log "Options: $*"

####################

on_exit() {
	echo -ne '\e[?25h'
	stty echo
}

trap on_exit EXIT
echo -ne '\e[?25l'
stty -echo

####################

cursor_x=0
cursor_y=0
(( covered = height * width ))
declare -A map
declare -A revealed

for i in $(seq 1 $mines); do
	log "Placing mine $i"
	place_mine
done

####################

print_map
print_cursor cursor_x cursor_y
while read -rsN1 key
do
	# read other bits
	read -rsN1 -t 0.0001 k1
	read -rsN1 -t 0.0001 k2
	key+=${k1}${k2}

	case "$key" in
		$'\e[A'|$'\e0A'|w) # up
			(( cursor_y > 0 )) || continue
			redraw $cursor_x $cursor_y
			(( cursor_y-- ))
			print_cursor $cursor_x $cursor_y
			;;
		$'\e[B'|$'\e0B'|s) # down
			(( cursor_y < height - 1 )) || continue
			redraw $cursor_x $cursor_y
			(( cursor_y++ ))
			print_cursor $cursor_x $cursor_y
			;;
		$'\e[C'|$'\e0C'|d) # right
			(( cursor_x < width - 1 )) || continue
			redraw $cursor_x $cursor_y
			(( cursor_x++ ))
			print_cursor $cursor_x $cursor_y
			;;
		$'\e[D'|$'\e0D'|a) # left
			(( cursor_x > 0 )) || continue
			redraw $cursor_x $cursor_y
			(( cursor_x-- ))
			print_cursor $cursor_x $cursor_y
			;;
		' ') # space
			reveal $cursor_x $cursor_y
			print_cursor $cursor_x $cursor_y
			if (( covered == mines )); then
				echo 'Gratuluję wygranej!'
				exit 0
			fi
			;;
		$'\n'|'f') # f, enter
			flag $cursor_x $cursor_y
			print_cursor $cursor_x $cursor_y
			;;
		'q'|$'\e') # q, esc
			echo "Do zobaczenia!"
			exit 0
			;;
	esac
	echo -ne "\e[u" # restore cursor
done
