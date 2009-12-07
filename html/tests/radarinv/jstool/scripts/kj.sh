#!/bin/bash

except=$1
except=${except:-1}
KILLABLE=`pgrep java`
for p in $KILLABLE
do
	if [ $except != $p ]; then
		kill $p
	fi
done
