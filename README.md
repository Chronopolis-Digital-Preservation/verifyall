# verifyall
Script to bag verifyvalid all bags on a replication server

Since this will need to run for days (from 20 to 5, depending
upon the speed of the connection to your storage), I tried to
write this so that it can be restarted if interrupted and pick
up where it left off.

Currently, there are about 2300 bags, total space about 72TB.

## documentation and sources
bagit description

https://www.digitalpreservation.gov/series/challenge/data-transfer-tools.html

bagit github

https://github.com/LibraryOfCongress/bagit-java

NOTE, I use version 4 because it includes a commandline utility

https://github.com/LibraryOfCongress/bagit-java/releases/download/v4.12.3/bagit-v4.12.3.zip

## requirements
```
# $BAG requires java
# probably works with almost any version, I'm using openjdk 11
```

## clone
Clone to somewhere or as someone with read access to the replication storage.

I don't run this on the replication server, so that it doesn't impact
replication performance.  My experience is that the data rate from
the NFS mount can reach 800MB/s, though it is often ONLY 400MB/s.

On the server running verifyall, I mount the storage read-only.  The
script only needs read access, but I also don't want any mistakes to
clobber the bags.
```
git clone https://github.com/Chronopolis-Digital-Preservation/verifyall.git
```

## configure
```
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

vi verifyall.sh
MNT=/scratch1/chronopolis-preservation
COMPLETED=completed
ALL=all
```

## run
```
./verifyall.sh >& verifyall.out&
```

## check progress
```
tail -f completed
or
tail -f verifyall.out
```

# monitor network performance
simple_network_monitor creates log of Bytes/sec, KBytes/second,
and MBytes/second

Thanks to Bernd Schlör <bernd.schloer@gwdg.de>

## configure
$NET is the path to the statistics for the interface to your storage

$LOG must be writable by whoever runs the monitor
```
vi simple_network_monitor
NET=/sys/class/net/ens192/statistics/rx_bytes
LOG=/var/log/chronopolis/transfer_rates
```

## run
```
./simple_network_monitor >& simple_network_monitor.out&
```

## monitor
```
tail -f /var/log/chronopolis/transfer_rates
Sun Mar 13 16:17:16 PDT 2022: 445634300 435189  424
Sun Mar 13 16:17:17 PDT 2022: 470905188 459868  449
Sun Mar 13 16:17:18 PDT 2022: 323010536 315439  308
...
```

