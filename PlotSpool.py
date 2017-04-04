#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
basic plotting of Neo/Zyla sCMOS Andor Solis spool files, to confirm you have settings correct.
"""
from pathlib import Path
from matplotlib.pyplot import figure,draw,pause,show
#
from dmcutils.neospool import readNeoSpool

INIFN = 'acquisitionmetadata.ini' # autogen from Solis
PL= True
IMAX = 500 # arbitrary max brightness

if __name__ == '__main__':
    from argparse import ArgumentParser
    p = ArgumentParser()
    p.add_argument('path',help='path to Solis spool files')
    p = p.parse_args()

    path = Path(p.path).expanduser()

    flist = sorted(path.glob('*.dat')) # list of spool files in this directory

    if not flist:
        raise FileNotFoundError('no spool files found in ',path)

    for f in flist:
        imgs,ticks = readNeoSpool(f,INIFN)

        if PL:
            ax = figure(1).gca()
            for I,t in zip(imgs,ticks):
                ax.imshow(I, vmax=IMAX)
                ax.set_title(f'tick: {t}')
                draw(); pause(0.01)

            ax = figure(2).gca()
            ax.hist(I.ravel(),bins=200)
            ax.set_yscale('log')
            show()