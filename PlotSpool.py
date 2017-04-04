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
    if path.is_dir():
        flist = sorted(path.glob('*.dat')) # list of spool files in this directory
    elif path.is_file():
        flist = [path]
    else:
        raise FileNotFoundError('no spool files found in ',path)

    for f in flist:
        imgs,ticks = readNeoSpool(f,INIFN)

        if PL:
            fg = figure(1)
            ax = fg.gca()
            hi = ax.imshow(imgs[0], vmax=IMAX)
            fg.colorbar(hi,ax=ax)
            ht = ax.set_title('')
            for I,t in zip(imgs,ticks):
                hi.set_data(I)
                ht.set_text(f'tick: {t}')

                draw(); pause(0.1)

        if HIST:
            ax = figure(2).gca()
            ax.hist(imgs[0,...].ravel(),bins=200)
            ax.set_yscale('log')

    show()