#!/bin/bash
# Argument = -i input -o output -f

usage() {
	echo "
SYNOPSIS
	usage: $0 [-i INPUT1 -i INPUT2 ...] [-o OUTPUT] [-u] [-h]

DESCRIPTION
	This script copy the content of INPUT1 , INPUT2, ...
	in OUTPUT.

OPTIONS
	-h      Show this message
	-i      Input file
	-o      Output file
	-u      Remove duplicated and sort

EXAMPLE
	Content of file1 and file2 before the command
		file1:
			a
			b
		file2:
			c
			e
			b
	$ $0 -i file1 -i file2 -o file1 -u
	Content of file1 and file2 after the command
		file1:
			a
			b
			c
			e
		file2:
			c
			e
			b
"
}

tmp=`mktemp`

exit_clean() {
	if [ -e $tmp ]; then
		rm $tmp
	fi
	exit $1
}

OUT=
UNIQ=false
while getopts "hi:o:u" OPTION; do
	case $OPTION in
		h)
			usage
			exit_clean 1
			;;
		i)
			IN=$OPTARG
			if [ ! -e "$IN" ]; then
				echo "$IN: No such file or directory"
				exit_clean 1
			fi
			if [ ! -f "$IN" ]; then
				echo "$IN is not a file"
				exit_clean 1
			fi
			cat "$IN" >> "$tmp"
			;;
		o)
			OUT=$OPTARG
			;;
		u)
			UNIQ=true
			;;
		?)
			usage
			exit_clean 1
			;;
	esac
done

if $UNIQ; then
	tmp2=`mktemp`
	sort "$tmp" > "$tmp2"
	uniq "$tmp2" > "$tmp"
fi

if [ -z "$OUT" ]; then
	cat "$tmp"
	exit_clean 0
fi

if [ -e "$OUT" ]; then
	if [ -f "$OUT" ]; then
		read -p "$OUT already exists. Overwrite it ? [y/N] " answer
		if [[ "x$answer" != "xy" ]] && [[ "x$answer" != "xY" ]]; then
			exit_clean 1
		fi
	else
		echo "$OUT exists and is not a file"
		exit_clean 1
	fi
fi

cat "$tmp" > "$OUT"
exit_clean 0
