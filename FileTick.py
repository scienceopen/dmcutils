#!/usr/bin/env python
"""
Reports first tick number in file vs filename
I don't think filename are monotonic w.r.t. ticks.
"""

from dmcutils.neospool import spoolparam,tickfile,spoolpath

INIFN = 'acquisitionmetadata.ini' # autogen from Solis


if __name__ == '__main__':
    from argparse import ArgumentParser
    p = ArgumentParser()
    p.add_argument('path',help='path to Solis spool files')
    p.add_argument('-o','--tickfn',help='HDF5 file to write with tick vs filename (for reading file in time order)')
    p = p.parse_args()

    flist = spoolpath(p.path)

    P = spoolparam(flist[0].parent/INIFN)
    F = tickfile(flist,P,p.tickfn)
