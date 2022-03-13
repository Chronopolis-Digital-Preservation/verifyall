#!/bin/bash

# $MNT is where replicationd stores bags
# expects
# depositor/bag
# ...

MNT=/scratch1/chronopolis-preservation

# Two files will be created
# $COMPLETED - remove this to start over
#    syntax "<status> <path>"
# $ALL       - compare to $COMPLETED to see progress
#    syntax "<path>"

COMPLETED=completed
ALL=all

# $BAG requires java
# probably works with almost any version, I'm using openjdk 11

BAG=bagit-4.10.0-SNAPSHOT/bin/bag

prog=`basename $0`
tmp=/tmp/$prog.$$
trap "rm -f $tmp; echo -n 'end ' ; date +%F-%T" EXIT

if [ ! -d $MNT ]; then
  echo "MISSING MNT $MNT"
  exit 1
fi

if [ ! -f $COMPLETED ]; then
  if ! touch $COMPLETED; then
    exit 1
  fi
fi

if ! java --version; then
  exit 1
fi
if ! $BAG --version; then
  exit 1
fi

if [ -f $ALL ]; then
  echo "OVERWRITING ALL $ALL"
fi

find $MNT -mindepth 2 -maxdepth 2 -type d -print > $ALL
if [ $? -ne 0 ]; then
  echo "FIND FAILED"
  exit 1
fi

echo -n "start "
date +%F-%T

while read path; do
 # expected syntax in $COMPETED is "<status> <path>$"
  if grep " ${path}$" $COMPLETED >/dev/null; then
    # echo "COMPLETED $path"
    continue
  fi
  if ! expr "$path" : [0-9a-zA-Z_/-]* >/dev/null; then
    echo "BAD PATH $path" >> $COMPLETED
    echo "BAD PATH $path"
    continue
  fi
  if [ ! -f $path/bagit.txt ]; then
    echo "MISSING bagit.txt $path" >> $COMPLETED
    echo "MISSING bagit.txt $path"
    continue
  fi
  echo -n "START $path "
  date +%F-%T
  $BAG verifyvalid --noresultfile $path >& $tmp
  if [ $? -ne 0 ]; then
    echo "VERIFY FAILED $path" >> $COMPLETED
    echo "VERIFY FAILED $path"
    cat $tmp
    continue
  fi
  echo "OK $path" >> $COMPLETED
  echo -n "OK $path "
  date +%F-%T
done < $ALL
