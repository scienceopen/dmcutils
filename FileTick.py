#!/usr/bin/env python
"""
Reports first tick number in file vs filename
I don't think spool filenames are monotonic w.r.t. ticks.

./FileTick.py ~/H/neo2012-12-25/spool_5/ -xy 320 270 -s 648 -z 4

./FileTick.py ~/data/testdmc

python FileTick.py z:\2017-04-27\spool
"""
from pathlib import Path
from dmcutils.neospool import spoolparam,tickfile,spoolpath
#sys.tracebacklimit=1
#
INIFN = 'acquisitionmetadata.ini' # autogen from Solis

def filetick(indir:Path, xy:tuple, stride:int, tickfn:Path, zerocols:int):
    """tickfile aborts before generating index if spool.h5 already exists"""

    flist = spoolpath(indir)
    if len(flist)==0:
        raise FileNotFoundError(f'no files found in {p.path}')

    P = spoolparam(flist[0].parent/INIFN, xy[0], xy[1], stride)

    F = tickfile(flist, P, tickfn, zerocols)

    return F


if __name__ == '__main__':
    import signal
    signal.signal(signal.SIGINT, signal.SIG_DFL)

    from argparse import ArgumentParser
    p = ArgumentParser()
    p.add_argument('path',help='path to Solis spool files')
    p.add_argument('tickfn',help='HDF5 file to write with tick vs filename (for reading file in time order)')
    p.add_argument('-xy',help='number of columns,rows',nargs=2,type=int,default=(640,540))
    p.add_argument('-s','--stride',help='number of header bytes',type=int,default=1296)
    p.add_argument('-z','--zerocols',help='number of zero columns',type=int,default=0)
    p = p.parse_args()

    F  = filetick(p.path, p.xy, p.stride, p.tickfn, p.zerocols)
