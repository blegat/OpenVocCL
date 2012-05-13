#!/bin/bash
en=true
while read line; do
	if $en; then
		ens=$line
		en=false
	else
		echo "$ens|$line"
		en=true
	fi
done
