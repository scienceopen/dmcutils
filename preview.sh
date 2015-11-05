#!/bin/bash

root=$1
nx=$2
ny=$3
[[ -d $root ]] || { echo "$root not a directory"; exit 1; }
[[ -z $ny ]] && { echo "need to enter x and y pixel shape"; exit 1; }
##### detect if server already running, if not, start it
nice -n 15 python Webserver.py 8088 2>>$HOME/server.log &
ret=$?
[[ $ret -ne 0 ]] && { echo "server already running?"; }
##### we use Windows Anaconda on Windows, arbitrary choice.
case "$(uname -s)" in
    CYGWIN*) root=$(cygpath --windows $root); pyloop=/cygdrive/c/Anaconda/python; ;;
    *) pyloop=python2 ;;
esac
#### every N seconds (600=10 minutes) update the preview.
# Note because of non-sequential file naming, this takes a few minutes each time, 
# proportional to the rapidly increasing number of spool files...
# maybe parsing .sifx would help immediately find the most recent file?
while :; do
    nice -n 19 $pyloop -u live_preview_neospool.py $root $nx $ny 2>>$HOME/live.log
    sleep 600
done
