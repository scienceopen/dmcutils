#!/usr/bin/env python3
from __future__ import division,absolute_import
import logging
from pathlib2 import Path
from pandas import read_csv
from datetime import datetime
from pytz import UTC
from numpy import uint16,uint64,fromfile,empty,percentile
from scipy.misc import bytescale,imsave
try:
    import cv2
except:
    pass  #fall back to scipy imsave, no time annotation

datatype=uint16
zerorows=8 #rows between image and header, all zeros, for 2015 Solis

def findnewest(path):
    assert path, '{} is empty'.format(path)
    path = Path(path).expanduser()
    assert path.exists(),'{} could not find'.format(path)
#%% it's a file
    if path.is_file():
        return path
#%% it's a directory
    flist = path.glob('*.dat')
    assert flist, 'no files found in {}'.format(path)

    # max(fl2,key=getmtime)                             # 9.2us per loop, 8.1 time cache Py3.5,  # 6.2us per loop, 18 times cache  Py27
    #max((str(f) for f in flist), key=getmtime)         # 13us per loop, 20 times cache, # 10.1us per loop, no cache Py27
    return max(flist, key=lambda f: f.stat().st_mtime) #14.8us per loop, 7.5times cache, # 10.3us per loop, 21 times cache Py27

def getframesize(path,inifn):
    if path.is_dir():
        inifn = path/p.inifile
    elif path.is_file():
        inifn = path.parent/p.inifile

    H = read_csv(str(inifn),delimiter='=',comment='[',index_col=0).iloc[:,0].rename(index=lambda x: x.strip())
    nxy  =  (int(H['AOIWidth']),int(H['AOIHeight']))
    Nframe = int(H['ImagesPerFile'])
    stride = int(H['AOIStride'])
    framebytes=int(H['ImageSizeBytes']) #including all headers & zeros


    if H['PixelEncoding'].strip().lower() != 'mono16':
        logging.warning('this program is only made for Mono16 pixel type, images may appear scrambled')

    return nxy,Nframe,stride,framebytes

def readNeoSpool(fn):
    #%% parse header
    nxy,Nframe,stridebytes,framebytes = getframesize(path,p.inifile)
    """ 16 bit """
    nx,ny=nxy
#    nimg   = nx * ny
    npixframe = (nx+zerorows)*ny

    assert framebytes == (npixframe * datatype(0).itemsize) + stridebytes
    filebytes = fn.stat().st_size
    if Nframe != filebytes // framebytes:
        logging.warning('file may be read incorrectly')
    else:
        logging.info('{} frames / file'.format(Nframe))

    frames = empty((Nframe,ny,nx),dtype=datatype)
    ticks  = empty(Nframe,dtype=uint64)
    with open(str(fn),'rb') as f: #FIxME: for Python 2.7 Numpy 1.10 bug with io.BufferedReader IOError
        for i in range(Nframe):
            frame = fromfile(f,dtype=uint16,count=npixframe).reshape((ny,nx+zerorows))
            frames[i,...] = frame[:,:-zerorows]

            #NOTE see histutils/parseNeoHeader.m for other numbers, which are probably useless. Use struct.unpack() with them
            ticks[i] = fromfile(f,dtype=uint64,count=stridebytes//8)[-2]
    return frames,ticks

def mean16to8(I):
    #%% take mean and scale images
    fmean = I.mean(axis=0)
    l,h = percentile(fmean,(0.5,99.5))
#%% 16 bit to 8 bit using scikit-image
    return bytescale(fmean,cmin=l,cmax=h)

def annowrite(I):
    try:
        cv2.putText(I, text=datetime.fromtimestamp(newfn.stat().st_mtime,tz=UTC).strftime('%x %X'), org=(3,35),
            fontFace=cv2.FONT_HERSHEY_SIMPLEX, fontScale=1.2,
            color=(255,255,255), thickness=2)
#%% write to disk
        cv2.imwrite('latest.png',I) #if using color, remember opencv requires BGR color order
    except NameError:
        imsave('latest.png',I)

if __name__ == '__main__':
    from argparse import ArgumentParser
    p = ArgumentParser(description='find newest file in directory, take mean of images, convert to PNG for web live preview')
    p.add_argument('path',help='path to search')
    p.add_argument('--inifile',help='filename to parse to get basic image shape parameters',default='acquisitionmetadata.ini')
    p = p.parse_args()
#%% find newest file to extract images from
    path = Path(p.path).expanduser()
    newfn = findnewest(path)
#%% read images and FPGA tick clock from this file
    frames,ticks = readNeoSpool(newfn)
#%% 16 bit to 8 bit, mean of image stack for this file
    f8bit = mean16to8(frames)
#%% put time on image and write to disk
    annowrite(f8bit)
