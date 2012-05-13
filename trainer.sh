#!/bin/bash
# Argument = -i input -o output -f

usage() {
	echo "
	usage: $0 -i INPUT -o OUTPUT [-f] [-v]

	This script ask you every word of INPUT
	and output the failed one in OUTPUT.

	OPTIONS:
	-h      Show this message
	-i      Input file
	-o      Output file
	-f      French to English
	-v      Verbose
	"
}

random_congrat() {
	ran=`date +%S` # number of seconds (this is pretty random)
	let "ran %= 6"
	case $ran in
		0)
			echo "Congratulation, your answer is perfectly correct !"
			;;
		1)
			echo "Your answer is as perfect as Linux is the best :)"
			;;
		2)
			echo "Perfection is here, I feel it"
			;;
		3)
			echo "Teach me master :o"
			;;
		4)
			echo "Mother of god 8-o"
			;;
		5)
			echo "This is the second best answer after '42'"
			;;
		?)
			echo "FATAL ERROR, please report it :)"
			;;
	esac
}

random_fail_mess() {
	ran=`date +%S` # number of seconds (this is pretty random)
	let "ran %= 6"
	case $ran in
		0)
			echo "Not quite :/"
			;;
		1)
			echo "Not exactly sir..."
			;;
		2)
			echo "Well tried but no :)"
			;;
		3)
			echo "*FACE PALM*"
			;;
		4)
			echo "Epic fail dude..."
			;;
		5)
			echo "You dumbass :)"
			;;
		?)
			echo "Yeah sure, and I'm fucking banana with wings..."
			;;
	esac
}

play() {
	OUT=$1
	FRTOEN=$2
	VERBOSE=$3
	echo "Let's play"
	inl=english
	oul=french
	if $FRTOEN; then
		inl=french
		oul=english
	fi
	while read line; do
		en=`echo $line | cut -d \| -f 1`
		fr=`echo $line | cut -d \| -f 2`
		ins=$en
		ous=$fr
		if $FRTOEN; then
			ins=$fr
			ous=$en
		fi
		echo "How would you translate this $inl sentence"
		echo "$ins"
		read -p "In $oul ? " ans
		if [ "x$ans" == "x$ous" ]; then
			random_congrat
			success=true
			read -p "Do you want to consider it as a fail anyway ? [y/N] " answer
			if [[ "x$answer" == "xy" ]] || [[ "x$answer" == "xY" ]]; then
				success=false
			fi
		else
			random_fail_mess
			echo "The answer was"
			echo "$ous"
			success=false
			read -p "Do you want to consider it as a success anyway ? [y/N] " answer
			if [[ "x$answer" == "xy" ]] || [[ "x$answer" == "xY" ]]; then
				success=true
			fi
		fi
	done
}

IN=
OUT=
FRTOEN=false
VERBOSE=false
while getopts "hi:o:fv" OPTION; do
	case $OPTION in
		h)
			usage
			exit 1
			;;
		i)
			IN=$OPTARG
			;;
		o)
			OUT=$OPTARG
			;;
		f)
			FRTOEN=true
			;;
		v)
			VERBOSE=true
			;;
		?)
			usage
			exit 1
			;;
	esac
done
if $VERBOSE; then
	echo "Verbose mode activated"
	if $FRTOEN; then
		echo "French to English activated"
	else
		echo "English to French activated"
	fi
fi

if [[ -z "$IN" ]] || [[ -z "$OUT" ]]; then
	usage
	exit 1
fi

if [ ! -e "$IN" ]; then
	echo "$IN: No such file or directory"
	exit 1
fi
if [ ! -f "$IN" ]; then
	echo "$IN is not a file"
	exit 1
fi
if [ -e "$OUT" ]; then
	if [ -f "$OUT" ]; then
		read -p "$OUT already exists. Overwrite it ? [y/N] " answer
		if [[ "x$answer" != "xy" ]] && [[ "x$answer" != "xY" ]]; then
			exit 1
		fi
	else
		echo "$OUT exists and is not a file"
		exit 1
	fi
fi

cat $IN | play "$OUT" $FRTOEN $VERBOSE
