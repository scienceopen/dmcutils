#!/usr/bin/env python
"""
Web server polling latest image (averaged over spool file) for Andor Neo Spool Files
uses OpenCV 3 with Python 3.6
Michael Hirsch

Prereqs: python -m pip install flask flask-limiter

Linux:
nice -n 19 python preview.py ~/datadir

Windows:
start /low python preview.py ~/datadir

Note that subprocesses have priority of calling function, so we don't need "nice"
in the Popen command.
"""
from pathlib import Path
from time import sleep
import sys
import subprocess

#
from dmcutils.neospool import preview_newest

#
sys.tracebacklimit = 5

serverlogfn = Path("~/server.log").expanduser()


def preview_image_web(datadir: Path, htmldir: Path, update: int, verbose: bool):
    datadir = Path(datadir).expanduser()
    htmldir = Path(htmldir).expanduser()
    if not datadir.is_dir():
        raise FileNotFoundError(f"{datadir} not found")
    if not htmldir.is_dir():
        raise FileNotFoundError(f"{htmldir} not found")

    servlog = serverlogfn.open("a")
    # %% detect if server already running, if not, start it
    subprocess.Popen(["python", "Webserver.py", "8088", str(htmldir)], stderr=servlog)
    # %% every N seconds update the preview
    ofn = htmldir / "latest.jpg"
    oldfset: set = set()

    while True:
        oldfset = preview_newest(datadir, ofn, oldfset, verbose=verbose)
        sleep(update)


if __name__ == "__main__":
    from argparse import ArgumentParser

    p = ArgumentParser()
    p.add_argument("datadir", help="directory to read preview data from")
    p.add_argument("--update", help="update rate [sec]", type=int, default=60)
    p.add_argument("--htmldir", help="directory to serve preview image from", default="static/")
    p.add_argument("-v", "--verbose", action="store_true")
    P = p.parse_args()

    preview_image_web(P.datadir, P.htmldir, P.update, P.verbose)
