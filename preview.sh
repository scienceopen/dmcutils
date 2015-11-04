#!/bin/bash

root=$1
nx=$2
ny=$3
[[ -d $root ]] || { echo "$root not a directory"; exit 1; }



for i in {0..360}; do
    pythonwin live_preview_neospool.py $root $nx $ny
    ret=$?
    [[ $ret -ne 0 ]] && { echo "python program error"; exit $ret; }
    sleep 60
done
