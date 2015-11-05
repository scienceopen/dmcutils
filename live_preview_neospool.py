#!/usr/bin/env python3
from __future__ import division,absolute_import
from six import PY2
#import logging
from datetime import datetime
from pytz import UTC
from os.path import join,getmtime,isdir,isfile,expanduser,getsize #unix epoch time
from glob import glob
from numpy import uint16,uint32,fromfile,empty,percentile
from scipy.misc import imsave,bytescale
import cv2
if PY2: FileNotFoundError = IOError

datatype=uint16
stride=8 #rows for header, mostly zeros

def findnewest(path):
    path = expanduser(path)

    if isfile(path):
        return path,getmtime(path)

    assert isdir(path)

    flist = glob(join(path,'*.dat'))
    if not flist:
        raise FileNotFoundError('no files found in {}'.format(path))

    newfn= max(flist, key=getmtime)
    return (newfn,getmtime(newfn))

def readNeoSpool(fn,nxy):
    """ 16 bit """
    nx,ny=nxy
#    nimg   = nx * ny
    nframe = (nx+stride)*ny
    bpp = 16

    framebytes = nframe * bpp//2

    filebytes = getsize(fn)
    Nframes = filebytes // framebytes
    print('{} frames / file'.format(Nframes))

    frames = empty((Nframes,ny,nx),dtype=datatype)
    with open(fn,'rb') as f:
        for i in range(Nframes):
            frame = fromfile(f,dtype=uint16,count=nframe).reshape((ny,nx+stride))
            frames[i,...] = frame[:,:-stride]
            head = frame[:,-stride:]
    return frames

def plotspool(F):
    from matplotlib.pyplot import figure,show,draw,pause
    from matplotlib.colors import LogNorm

    fg = figure()
    ax = fg.gca()
    for f in F:
        ax.imshow(f,cmap='gray',norm=LogNorm(),origin='lower',interpolation='none')
        draw(), pause(0.1)

if __name__ == '__main__':
    from argparse import ArgumentParser
    p = ArgumentParser(description='find newest file in directory')
    p.add_argument('path',help='path to search')
    p.add_argument('nxy',help='x,y pixels after binning',nargs=2,type=int)
    p.add_argument
    p = p.parse_args()

    newfn,mtime = findnewest(p.path)
    frames = readNeoSpool(newfn,p.nxy)
    fmean = frames.mean(axis=0)
    l,h = percentile(fmean,(0.5,99.5))
#%% annotated image
    f8bit = bytescale(fmean,cmin=l,cmax=h)
    cv2.putText(f8bit, text=datetime.fromtimestamp(mtime,tz=UTC).strftime('%x %X'), org=(3,15),
                fontFace=cv2.FONT_HERSHEY_PLAIN, fontScale=1.2,
                color=(32,165,218), thickness=2)
#%% write to disk
    imsave('latest.png',f8bit)

    #plotspool([fmean])
   # show()
