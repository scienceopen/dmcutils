#!/usr/bin/env python
"""
basic plotting of Neo/Zyla sCMOS Andor Solis spool files, to confirm you have settings correct.

ticks[-1]-ticks[-2]   2015-10-19
615517
>>> 615517/0.0153846
40008645.008645006

ticks[1]-ticks[0]  2017-04-05
1333372
>>> 1333372/0.0333248
40011402.9191473
>>>
"""
from datetime import datetime,timedelta
from matplotlib.pyplot import figure,draw,pause,show
#import seaborn
#
from dmcutils.neospool import readNeoSpool,spoolparam,spoolpath

INIFN = 'acquisitionmetadata.ini' # autogen from Solis
PL= True
IMAX = 400 # arbitrary max brightness
HIST=False

if __name__ == '__main__':
    from argparse import ArgumentParser
    p = ArgumentParser()
    p.add_argument('path',help='path to Solis spool files')
    p.add_argument('-k','--kinetic',help='kinetic time [sec]',type=float)
    p.add_argument('-s','--tstart',help='start time [Unix epoch seconds]',type=float)
    p = p.parse_args()

    flist = spoolpath(p.path)

    P = spoolparam(flist[0].parent/INIFN)
    P['kinetic'] = p.kinetic
    P['nfile'] = 0
    if P['kinetic'] is not None:
        if p.tstart is None:
            tstart = flist[0].stat().st_mtime - P['kinetic']*P['nframe']
        elif isinstance(p.tstart,(float,int)):
            tstart = p.tstart
        else:
            raise TypeError('tstart is Unix epoch seconds')
        tstartdt = datetime.utcfromtimestamp(tstart)
#%% optional plotting
    if PL:
        imgs,ticks,tsec = readNeoSpool(flist[0],P)
        fg = figure(1)
        ax = fg.gca()
        hi = ax.imshow(imgs[0], vmax=IMAX)
        fg.colorbar(hi,ax=ax)
        ht = ax.set_title('')

    for i,f in enumerate(flist):
        P['nfile'] = i
        imgs,ticks,tsec = readNeoSpool(f, P)

        if PL:
            for j in range(P['nframefile']):
                hi.set_data(imgs[i,...])
                ttxt = f'{f.name}\ntick: {ticks[j]} '
                if tsec is not None:
                    tdt = tstartdt + timedelta(seconds=tsec[j])
                    ttxt += 'sec: ' + str(tdt)[:-3]
                ht.set_text(ttxt)

                draw(); pause(0.01)

        if HIST:
            ax = figure(2).gca()
            ax.hist(imgs[0,...].ravel(),bins=200)
            ax.set_yscale('log')

    show()