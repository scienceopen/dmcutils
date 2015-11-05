#!/usr/bin/env python3
from __future__ import division,absolute_import
from pathlib2 import Path
from six import PY2
#import logging=
from datetime import datetime
from pytz import UTC
from os.path import getmtime,getsize #unix epoch time
from numpy import uint16,uint32,fromfile,empty,percentile
from scipy.misc import bytescale
import cv2
if PY2: FileNotFoundError = IOError

datatype=uint16
stride=8 #rows for header, mostly zeros

def findnewest(path):
    assert path
    path = Path(path).expanduser()
    assert path.exists()
#%% it's a file
    if path.is_file():
        return path
#%% it's a directory
    flist = path.glob('*.dat')
    if not flist:
        raise FileNotFoundError('no files found in {}'.format(path))

    # max(fl2,key=getmtime)                             # 9.2us per loop, 8.1 time cache Py3.5,  # 6.2us per loop, 18 times cache  Py27
    #max((str(f) for f in flist), key=getmtime)         # 13us per loop, 20 times cache, # 10.1us per loop, no cache Py27
    return max(flist, key=lambda f: f.stat().st_mtime) #14.8us per loop, 7.5times cache, # 10.3us per loop, 21 times cache Py27

def getframesize(inifn,nxy):


    return nxy

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

if __name__ == '__main__':
    from argparse import ArgumentParser
    p = ArgumentParser(description='find newest file in directory')
    p.add_argument('path',help='path to search')
    g = p.add_mutually_exclusive_group()
    g.add_argument('--inifile',help='filename to parse to get basic image shape parameters',default='acquisitionmetadeta.ini')
    g.add_argument('--nxy',help='x,y pixels after binning, if aquisitionmetadata.ini is not available',nargs=2,type=int)
    p = p.parse_args()

    newfn = findnewest(p.path)
    nxy = getframesize(p.inifile,p.nxy)
    frames = readNeoSpool(newfn,nxy)
#%% take mean and scale images
    fmean = frames.mean(axis=0)
    l,h = percentile(fmean,(0.5,99.5))
#%% annotated grayscale image
    f8bit = bytescale(fmean,cmin=l,cmax=h)
    cv2.putText(f8bit, text=datetime.fromtimestamp(newfn.stat().st_mtime,tz=UTC).strftime('%x %X'), org=(3,15),
                fontFace=cv2.FONT_HERSHEY_PLAIN, fontScale=1.2,
                color=(255,255,255), thickness=2)
#%% write to disk
    cv2.imwrite('latest.png',f8bit) #if using color, remember opencv requires BGR color order
