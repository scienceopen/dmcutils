#!/usr/bin/env python
"""
Reports first tick number in file vs filename
I don't think filename are monotonic w.r.t. ticks.
"""
from pathlib import Path
#
from dmcutils.neospool import spoolparam,tickfile

INIFN = 'acquisitionmetadata.ini' # autogen from Solis


if __name__ == '__main__':
    from argparse import ArgumentParser
    p = ArgumentParser()
    p.add_argument('path',help='path to Solis spool files')
    p = p.parse_args()

    path = Path(p.path).expanduser()
    if path.is_dir():
        flist = sorted(path.glob('*.dat')) # list of spool files in this directory
    elif path.is_file():
        flist = [path]
    else:
        raise FileNotFoundError('no spool files found in ',path)

    P = spoolparam(flist[0].parent/INIFN)
    F = tickfile(flist,P)
#%% print tick vs. filename
    print(F)