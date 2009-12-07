#!/bin/sh

files=$@
REMCOMSCRIPT=~/bin/remccoms3.sed
for f in $files
do
  if [ -e $f ]; then
    ### remove comments ### trim repeated whitespaces ### collapse lines ### trim starting, trailing whitespaces
    ##./remccoms3.sed < $f | tr -s [:blank:] | tr -d '\n' | sed 's/^[ \t]*//;s/[ \t]*$//' > $f.new ### working version
    ### \t space or space \t probably cannot be contracted since they are different!
    $REMCOMSCRIPT < $f | tr -s [:blank:] | tr -d '\n' | sed 's/^[\t]*//;s/[ \t]*$//' | tr -s \t > $f.new ### testing 
  fi
done

