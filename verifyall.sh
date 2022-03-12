#!/bin/bash

prog=`basename $0`
tmp=/tmp/$prog.$$
trap "rm -f $tmp; echo -n 'end ' ; date +%F-%T" EXIT

MNT=/scratch1/chronopolis-preservation
COMPLETED=completed
ALL=all

if [ ! -d $MNT ]; then
  echo "MISSING MNT $MNT"
  exit 1
fi

if [ ! -f $COMPLETED ]; then
  touch $COMPLETED
fi

if [ -f $ALL ]; then
  echo "OVERWRITING ALL $ALL"
fi

find $MNT -mindepth 2 -maxdepth 2 -type d -print > $ALL

echo -n "start "
date +%F-%T

while read path; do
  if ! expr "$path" : [0-9a-zA-Z_/-]* >/dev/null; then
    echo "BAD PATH $path"
     continue
  fi
  if grep $path $COMPLETED >/dev/null; then
    echo "COMPLETED $path"
    continue
  fi
  if [ ! -f $path/bagit.txt ]; then
    echo "$path MISSING bagit.txt" >> $COMPLETED
    echo "MISSING bagit.txt $path"
    continue
  fi
  echo -n "START $path "
  date +%F-%T
  bag verifyvalid --noresultfile $path >& $tmp
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
