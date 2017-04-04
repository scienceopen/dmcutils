#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
basic plotting of Neo/Zyla sCMOS Andor Solis spool files, to confirm you have settings correct.
"""
from pathlib import Path
from matplotlib.pyplot import figure,draw,pause,show
#import seaborn
#
from dmcutils.neospool import readNeoSpool

INIFN = 'acquisitionmetadata.ini' # autogen from Solis
PL= True
IMAX = 400 # arbitrary max brightness
HIST=False

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
            fg = figure(1)
            ax = fg.gca()
            for I,t in zip(imgs,ticks):
                hi = ax.imshow(I, vmax=IMAX)
                ax.set_title(f'tick: {t}')
                fg.colorbar(hi,ax=ax)
                draw(); pause(0.1)

        if HIST:
            ax = figure(2).gca()
            ax.hist(imgs[0,...].ravel(),bins=200)
            ax.set_yscale('log')
            show()