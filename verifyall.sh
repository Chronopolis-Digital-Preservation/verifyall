#!/bin/bash

# $MNT is where replicationd stores bags
# expects
# depositor/bag
# ...

MNT=/scratch1/chronopolis-preservation

# Two files will be created
# $COMPLETED - remove this to start over
#    syntax "<status> <timestamp> <path>"
# $ALL       - compare to $COMPLETED to see progress
#    syntax "<path>"

COMPLETED=completed
ALL=all

# $BAG requires java
# probably works with almost any version, I'm using openjdk 11

BAG=bagit-4.10.0-SNAPSHOT/bin/bag

prog=$(basename $0)
tmp=/tmp/$prog.$$
trap "rm -f $tmp; echo -n 'end '; date +%F-%T" EXIT

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

date=$(date +%F-%T)
echo "start $date"

while read path; do
 # expected syntax in $COMPETED is "<status> <timestamp> <path>$"
  if grep " ${path}$" $COMPLETED >/dev/null; then
    echo "COMPLETED $path"
    continue
  fi
  if ! expr "$path" : [0-9a-zA-Z_/-]* >/dev/null; then
    date=$(date +%F-%T)
    echo "BAD PATH $date $path" >> $COMPLETED
    echo "BAD PATH $date $path"
    continue
  fi
  if [ ! -f $path/bagit.txt ]; then
    date=$(date +%F-%T)
    echo "MISSING bagit.txt $date $path" >> $COMPLETED
    echo "MISSING bagit.txt $date $path"
    continue
  fi
  date=$(date +%F-%T)
  echo "START $path $date"
  $BAG verifyvalid --noresultfile $path >& $tmp
  res=$?
  # $BAG returns 130 when it gets SIGINT
  # bash ignores SIGINT when child exits with 130
  # so we must exit when $BAG returns 130
  if [ $res -eq 130 ]; then
    exit 0
  fi
  if [ $res -ne 0 ]; then
    date=$(date +%F-%T)
    echo "VERIFY FAILED $date $path" >> $COMPLETED
    echo "VERIFY FAILED $date $path"
    cat $tmp
    continue
  fi
  date=$(date +%F-%T)
  echo "OK $date $path" >> $COMPLETED
  echo "OK $date $path"
done < $ALL
