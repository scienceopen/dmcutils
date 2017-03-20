#!/bin/bash
# simple web server with polling of latest image for Andor Neo Spool Files
# uses OpenCV 3.2 with Python 3.6
# Michael Hirsch
#
# Prereqs: pip install flask flask-limiter
#
# Usage:  ./preview.sh ~/datadir

root=$1
[[ -d $root ]] || { echo "$root not a directory"; exit 1; }
##### detect if server already running, if not, start it
nice -n 15 python3 Webserver.py 8088 2>>$HOME/server.log &
ret=$?
[[ $ret -ne 0 ]] && { echo "server already running?"; }
##### we use Windows Anaconda on Windows, arbitrary choice.
case "$(uname -s)" in
    CYGWIN*) root=$(cygpath --windows $root); pyloop=/cygdrive/c/Anaconda3/python; ;;
    *) pyloop=python3 ;;
esac
#### every N seconds (600=10 minutes) update the preview.
# Note because of non-sequential file naming, this takes a few minutes each time, 
# proportional to the rapidly increasing number of spool files...
while :; do
    $pyloop -u ../andor-scmos-examples/GrabImage.py
    nice -n 19 $pyloop -u live_preview_neospool.py $root 2>>$HOME/live.log
    sleep 600
done
