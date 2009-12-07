#!/bin/bash

FILES=`ls`

for f in $FILES; do
	if [ -e $f ]; then
		if [ "~" = ${f:(-1)}  ]; then
			echo rm $f
			rm $f
		#else
			#echo "$f does not have the right suffix (~):" ${f:(-1)}
			
		fi
	else
		echo $f does not exist	
	fi
done
