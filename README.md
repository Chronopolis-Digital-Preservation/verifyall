# verifyall
Script to bag verifyvalid all bags on a replication server

# requirements
```
# $BAG requires java
# probably works with almost any version, I'm using openjdk 11
```

# clone
```
git clone https://github.com/Chronopolis-Digital-Preservation/verifyall.git
```

# configure
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

# run
```
./verifyall.sh >& verifyall.out&
```

# check progress
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
Replace ens192 with the network interface to your storage
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

