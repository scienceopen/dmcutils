#!/bin/bash

root=$1
nx=$2
ny=$3
[[ -d $root ]] || { echo "$root not a directory"; exit 1; }

#todo detect if server already running
python Webserver.py 8088 2>>$HOME/server.log &
ret=$?
[[ $ret -ne 0 ]] && { echo "server already running?"; exit $ret; }

while :; do
    /cygdrive/c/Anaconda/python -u live_preview_neospool.py $root $nx $ny 2>>$HOME/live.log
    ret=$?
    [[ $ret -ne 0 ]] && { echo "python program error"; exit $ret; }
    sleep 600
done
