#!/bin/bash
# Argument = -i input -o output -f

usage() {
	echo "
SYNOPSIS
	$0 -i INPUT -o OUTPUT [-s SAVE] [-c] [-f] [-h] [-v]

DESCRIPTION
	This script ask you every word of INPUT
	and output the failed one in OUTPUT.
	If you don't have time to do them all,
	you can save the INPUT you didn't do
	in SAVE.
	Every line of input must contain two
	sentences separated by a '|'

OPTIONS
	-c      Activate colored output
	-f      French to English
	-h      Show this message
	-i      Input file
	-o      Output file
	-s      Save file
	-v      Verbose

INTERACTIVE
	After each guess, you are gently informed of
	its correctness. You can then choose to
	change its decision by saying 'y' (yes) or
	'n' (no).
	If you want to save your changes, enter 's'
	instead. You will have the opportunity to
	change its decision afterwards.

EXAMPLE
	Content of file1 and file2 before the command
		file1:
			House|Maison
			Miscellaneous|Divers
			Dog|Chien
		file2:
			Odd|Impair
	$ $0 -i file1 -s file1 -o file2
	The user successfully guess 'House' but fail
	for 'Miscellaneous'. He saves with 's'
	before 'Dog'.
	Content of file1 and file2 after the command
		file1:
			Dog|Chien
		file2:
			Odd|Impair
			Miscellaneous|Divers
"
}

totally_badass_random() {
	ran=`date +%S`
	if [ "${ran:0:1}" == "0" ]; then # interpreted as base 8 by 'let' command which is not desired and crash for 08 and 09
		ran="${ran:1}"
	fi
	echo $ran
}

random_congrat() {
	ran=`totally_badass_random`
	let "ran %= 6"
	case $ran in
		0)
			s="Congratulation, your answer is perfectly correct !"
			;;
		1)
			s="Your answer is as perfect as Linux is the best :)"
			;;
		2)
			s="Perfection is here, I feel it"
			;;
		3)
			s="Teach me master :o"
			;;
		4)
			s="Mother of god 8-o"
			;;
		5)
			s="This is the second best answer after '42'"
			;;
		?)
			echo "FATAL ERROR, please report it :)"
			;;
	esac
	green $s
}

random_fail_mess() {
	ran=`totally_badass_random`
	let "ran %= 6"
	case $ran in
		0)
			s="Not quite :/"
			;;
		1)
			s="Not exactly sir..."
			;;
		2)
			s="Well tried but no :)"
			;;
		3)
			s="*FACE PALM*"
			;;
		4)
			s="Epic fail dude..."
			;;
		5)
			s="Yeah sure, and I'm fucking banana with wings..."
			;;
		?)
			echo "FATAL ERROR, please report it :)"
			;;
	esac
	red $s
}

IN=
OUT=
SAVE=
FRTOEN=false
VERBOSE=false
COLOR_ON=false
while getopts "hi:o:s:fvc" OPTION; do
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
		s)
			SAVE=$OPTARG
			;;
		f)
			FRTOEN=true
			;;
		v)
			VERBOSE=true
			;;
		c)
			COLOR_ON=true
			;;
		?)
			usage
			exit 1
			;;
	esac
done

color_test() {
	if $COLOR_ON; then
		echo -en "\033[$1m"
	fi
}

color_off() {
	color_test "0"
}

yellow_on() {
	color_test "1;33"
}

green_on() {
	color_test "1;32"
}

red_on() {
	color_test "1;31"
}

yellow() {
	yellow_on
	echo $1
	color_off
}

green() {
	green_on
	echo $1
	color_off
}

red() {
	red_on
	echo $1
	color_off
}

color_off

if $VERBOSE; then
	echo "Verbose mode activated"
	if $FRTOEN; then
		echo "French to English activated"
	else
		echo "English to French activated"
	fi
	if $COLOR_ON; then
		red_on
		echo -n "Color "
		green_on
		echo "activated"
		color_off
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
		#read -p "$OUT already exists. Overwrite it ? [y/N] " answer
		#if [[ "$answer" != "y" ]] && [[ "$answer" != "Y" ]]; then
			#exit 1
		#fi
		echo "$OUT already exists. The fails will be appended at the end of it."
	else
		echo "$OUT exists and is not a file"
		exit 1
	fi
fi

echo "Let's play"
inl=english
oul=french
if $FRTOEN; then
	inl=french
	oul=english
fi
IFS=$'\n'
saving_mode=false
for line in `sort -R $IN`; do
	if $saving_mode; then
		echo $line >> $filename
		continue
	fi
	en=`echo $line | cut -d \| -f 1`
	fr=`echo $line | cut -d \| -f 2`
	ins=$en
	ous=$fr
	if $FRTOEN; then
		ins=$fr
		ous=$en
	fi
	echo -n "How would you translate the $inl sentence "
	yellow "$ins"
	#read -p "In $oul ? " ans
	echo -n "In $oul ? "
	yellow_on
	read ans
	color_off
	save=false
	if [ "$ans" == "$ous" ]; then
		random_congrat
		success=true
		answer="s"
		while [[ "$answer" == "s" ]] || [[ "$answer" == "S" ]]; do
			read -p "Do you want to consider it as a fail anyway ? [y/N/s] " answer
			if [[ "$answer" == "y" ]] || [[ "$answer" == "Y" ]]; then
				success=false
			elif [[ "$answer" == "s" ]] || [[ "$answer" == "S" ]]; then
				echo "Ok, we'll go to the save menu but before, answer to this question please :)"
				save=true
			fi
		done
	else
		random_fail_mess
		echo -n "The answer was "
		yellow "$ous"
		success=false
		answer="s"
		while [[ "$answer" == "s" ]] || [[ "$answer" == "S" ]]; do
			read -p "Do you want to consider it as a success anyway ? [y/N/s] " answer
			if [[ "$answer" == "y" ]] || [[ "$answer" == "Y" ]]; then
				success=true
			elif [[ "$answer" == "s" ]] || [[ "$answer" == "S" ]]; then
				echo "Ok, we'll go to the save menu but before, answer to this question please :)"
				save=true
			fi
		done
	fi
	if ! $success; then
		echo $line >> $OUT
	fi
	if $save; then
		echo "Your current fails have been stored in $OUT."
		answer=
		if [ -z $SAVE ]; then
			read -p "It is possible to store the ones not tried yet in a file so you can resume later. Do you want to do it ? [Y/n/c] " answer
		fi
		store=true
		cancel=false
		if [[ "$answer" == "n" ]] || [[ "$answer" == "N" ]]; then
			store=false
		elif [[ "$answer" == "c" ]] || [[ "$answer" == "C" ]]; then
			echo "Saving cancelled. Resuming now..."
			cancel=true
		fi
		if ! $cancel; then
			valid=false
			resume_no_save=false
			if $store; then
				filename=$SAVE
				while ! $valid; do
					if [ -z $filename ]; then
						read -p "Enter the filename where you want to save: " filename
					fi
					valid=true
					if [ -e $filename ]; then
						valid=false
						if [ -f $filename ]; then
							read -p "$filename already exists, do you want to overwrite it ? [y/N] " answer
							if [[ "$answer" == "y" ]] || [[ "$answer" == "Y" ]]; then
								valid=true
								echo -n "" > $filename
							else
								read -p "Do you want to append to it ? [y/N] " answer
								if [[ "$answer" == "y" ]] || [[ "$answer" == "Y" ]]; then
									valid=true
								fi
							fi
						fi
					fi
					if ! $valid; then
						echo "$filename is not a valid filename"
						read -p "Do you want to resume now ? [y/N] " answer
						if [[ "$answer" == "y" ]] || [[ "$answer" == "Y" ]]; then
							valid=true
							resume_no_save=true
						else
							read -p "Do you still want to store it ? [Y/n] " answer
							if [[ "$answer" == "n" ]] || [[ "$answer" == "N" ]]; then
								store=false
								valid=true
							fi
						fi
					fi
					if ! $valid; then
						filename=
					fi
				done
			fi
			if ! $store; then
				exit 0
			fi
			if ! $resume_no_save; then
				saving_mode=true
			fi
		fi
	fi
done
