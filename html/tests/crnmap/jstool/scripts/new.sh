#!/bin/bash

FILES=`ls`

for f in $FILES; do
	if [ -e $f ]; then
		if [ ".new" = ${f:(-4)}  ]; then
			echo mv $f ${f%.new}
			mv $f ${f%.new}
			echo mv $f
		else
			echo $f does not have the right suffix: ${f:(-4)}.
		fi
	else
		echo $f does not exist	
	fi
done
