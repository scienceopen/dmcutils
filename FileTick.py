#!/usr/bin/env python
"""
Reports first tick number in file vs filename
I don't think filename are monotonic w.r.t. ticks.
"""
from pathlib import Path
import numpy as np
from pandas import Series
#
from dmcutils.neospool import readNeoSpool,spoolparam

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

    ticks = np.empty(len(flist),dtype=np.uint64)
    for i,f in enumerate(flist):
        ticks[i]  = readNeoSpool(f,P,True)

    F = Series(index=ticks,data=[f.stem for f in flist])


#%% print results
    print(F)