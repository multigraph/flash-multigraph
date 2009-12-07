#!/bin/bash

if [ "$#" -lt "3" ]; then
	echo "Insufficient file parameters"
	exit -1
fi

RANDOMINT=$RANDOM
for f in $@
do
	if ! [ -f $f ]; then
		continue
	fi
	sed -e "s@$1@$2@g" $f > $f.new.$RANDOMINT
done
