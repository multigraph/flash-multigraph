#!/bin/bash

if [ "$#" -eq "0" ]; then
	echo "Insufficient suffix parameter"
	exit -1
fi

oldsuffix=$1
newsuffix=""
if [ "$#" -eq "2" ]; then
	newsuffix=$2
fi

files=`ls -1 *$oldsuffix`
for f in $files
do
	cp $f ${f/$oldsuffix/$newsuffix}
done

##echo "Remove original files?"
##rm -i *$oldsuffix

