#!/bin/bash

root=$1
nx=$2
ny=$3
[[ -d $root ]] || { echo "$root not a directory"; exit 1; }
[[ -z $ny ]] && { echo "need to enter x and y pixel shape"; exit 1; }
#####
#todo detect if server already running
python Webserver.py 8088 2>>$HOME/server.log &
ret=$?
[[ $ret -ne 0 ]] && { echo "server already running?"; }
#####
case "$(uname -s)" in
    CYGWIN*) root=$(cygpath --windows $root); pyloop=/cygdrive/c/Anaconda/python; ;;
    *) pyloop=python2 ;;
esac
####
while :; do
    $pyloop -u live_preview_neospool.py $root $nx $ny 2>>$HOME/live.log
    sleep 600
done
