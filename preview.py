#!/usr/bin/env python
"""
UNTESTED NOT YET WORKING

simple web server with polling of latest image for Andor Neo Spool Files
uses OpenCV 3 with Python 3.6
Michael Hirsch

Prereqs: pip install flask flask-limiter

./preview.py ~/datadir
"""
from pathlib import Path
from time import sleep
import sys
import subprocess
#
from dmcutils.neospool import preview_newest
#
sys.tracebacklimit = 5

serverlogfn = Path('~/server.log').expanduser()
previewlogfn = Path('~/live.log').expanduser()

def preview_image_web(datadir:Path, htmldir:Path, verbose:bool):
    datadir = Path(datadir).expanduser()
    htmldir = Path(htmldir).expanduser()
    if not datadir.is_dir():
        raise FileNotFoundError(f'{datadir} not found')
    if not htmldir.is_dir():
        raise FileNotFoundError(f'{htmldir} not found')

    servlog = serverlogfn.open('a')
# %% detect if server already running, if not, start it
    # 'nice','-n','15',
    subprocess.Popen(['python','Webserver.py','8088', str(htmldir)],
                     stderr=servlog)

# %% every N seconds update the preview
    ofn = htmldir/'latest.jpg'
    oldfset = set()

    while True:
        oldfset = preview_newest(datadir, ofn, oldfset, verbose=verbose)
        sleep(30)

if __name__ == '__main__':
    from argparse import ArgumentParser
    p = ArgumentParser()
    p.add_argument('datadir',help='directory to read preview data from')
    p.add_argument('--htmldir',help='directory to serve preview image from',
                    default='static/')
    p.add_argument('-v','--verbose',action='store_true')
    p = p.parse_args()

    preview_image_web(p.datadir, p.htmldir, p.verbose)

