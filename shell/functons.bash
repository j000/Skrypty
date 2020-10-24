index() {
	# log "index(${1-0}, ${2-0})"
	tmp=$((${2-0} * ${width-0} + ${1-0}))
	return $tmp
}

random() {
	[[ $# -eq 0 ]] && return $RANDOM
	tmp=$RANDOM
	cutoff=$((32767 % $1))
	while [[ $tmp -le $cutoff ]]; do
		tmp=$RANDOM
	done
	return $((1 + $tmp % $1))
}

####################

change_char() {
	[[ $# -eq 0 ]] && echo " "
	case $1 in
		-1 )
			echo 'M';;
		* )
			echo $1;;
	esac
}

####################

place_mine(){
	while
		random $width
		x=$?
		random $height
		y=$?
		index $x $y
		ind=$?
		[[ ${map[$ind]:=0} -eq -1 ]]
	do :;done

	log "Mine is on $x $y ($ind)"
	map[$ind]=-1

	for dy in -1 0 1; do
		for dx in -1 0 1; do
			[[ $dx -eq 0 && $dy -eq 0 ]] && continue
			[[ $x -eq 1 && $dx -eq -1 ]] && continue
			[[ $x -eq $width && $dx -eq 1 ]] && continue
			[[ $y -eq 1 && $dy -eq -1 ]] && continue
			[[ $y -eq $height && $dy -eq 1 ]] && continue
			index $(($x + $dx)) $(($y + $dy))
			tmp=$?
			[[ ${map[$tmp]-0} -eq -1 ]] && continue
			map[$tmp]=$((${map[$tmp]-0} + 1))
		done
	done
}

print_map() {
	echo
	echo -n "  "
	for x in $(seq $width); do
		echo -n " $x "
	done
	echo
	for y in $(seq $height); do
		echo -n "$y "
		for x in $(seq $width); do
			index $x $y
			ind=$?
			echo -n " $(change_char ${map[$ind]- }) "
		done
		echo
	done
}
