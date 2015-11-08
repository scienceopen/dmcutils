#!/bin/bash
# simple web server with polling of latest image for Andor Neo Spool Files
# uses OpenCV 3.0 with Python 3.4/3.5
# Michael Hirsch
#
# Prereqs: flask flask-limiter pathlib2


root=$1
[[ -d $root ]] || { echo "$root not a directory"; exit 1; }
##### detect if server already running, if not, start it
nice -n 15 python Webserver.py 8088 2>>$HOME/server.log &
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
    nice -n 19 $pyloop -u live_preview_neospool.py $root 2>>$HOME/live.log
    sleep 600
done
