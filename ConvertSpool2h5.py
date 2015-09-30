#!/usr/bin/env python3
"""
Michael Hirsch
Sept 2015
"""
from __future__ import division,absolute_import
import h5py
from os.path import expanduser,join
from numpy import arange,asarray,empty,int16
from glob import glob
#
from histutils.rawDMCreader import dmcconvert,doPlayMovie,doplotsave
from histutils.timedmc import frame2ut1

datatype=int16

def h5toh5(fn,kineticsec,startutc):
    with h5py.File(expanduser(fn),'r',libver='latest') as f:
        data = f['/rawimg'].value

    rawind = arange(data.shape[0])+1

    ut1 = frame2ut1(startutc,kineticsec,rawind)

    return data,rawind,ut1

def oldspool(path,xy,bn,kineticsec,startutc):
    import matlab.engine
    eng = matlab.engine.start_matlab()

    path = expanduser(path)
    flist = glob(join(path,'*.dat'))
    nfile = len(flist)
    print('Found {} .dat files in {}'.format(nfile,path))

    nx,ny= xy[0]//bn[0], xy[1]//bn[1]
    data = empty((nfile,ny,nx),dtype=datatype) #NOTE: Assumes one frame per file!
    for i,f in enumerate(flist):
       print('processing {}   {} / {}'.format(f,i+1,nfile))
       datmat = eng.readNeoPacked12bit(f, nx,ny)
       assert datmat.size == (ny,nx)
       data[i,...] = asarray(datmat,dtype=datatype)

    eng.quit()

    return data,None,None

if __name__ == "__main__":
    from argparse import ArgumentParser
    p = ArgumentParser(description='Andor Neo Spool reader, plotter, converter')
    p.add_argument('path',help='path containing 12-bit Neo spool files in broken format (2008-spring 2011)')
    p.add_argument('-p','--pix',help='nx ny  number of x and y pixels respectively',nargs=2,default=(2544,2160),type=int)
    p.add_argument('-b','--bin',help='nx ny  number of x and y binning respectively',nargs=2,default=(1,1),type=int)
    p.add_argument('-m','--movie',help='seconds per frame. ',type=float)
    p.add_argument('-c','--clim',help='min max   values of intensity expected (for contrast scaling)',nargs=2,type=float)
    p.add_argument('-k','--kineticsec',help='kinetic rate of camera (sec)  = 1/fps',type=float)
    p.add_argument('--rotccw',help='rotate CCW value in 90 deg. steps',type=int,default=0)
    p.add_argument('--transpose',help='transpose image',action='store_true')
    p.add_argument('--flipud',help='vertical flip',action='store_true')
    p.add_argument('--fliplr',help='horizontal flip',action='store_true')
    p.add_argument('-s','--startutc',help='utc time of nights recording')
    p.add_argument('-o','--output',help='extract raw data into this file [h5,fits,mat]')
    p.add_argument('--avg',help='return the average of the requested frames, as a single image',action='store_true')
    p.add_argument('--hist',help='makes a histogram of all data frames',action='store_true')
    p.add_argument('-v','--verbose',help='debugging',action='count',default=0)
    p.add_argument('--fire',help='fire filename')
    p = p.parse_args()

    params = {'kineticsec':p.kineticsec,'rotccw':p.rotccw,'transpose':p.transpose,
              'flipud':p.flipud,'fliplr':p.fliplr,'fire':p.fire}

    rawImgData,rawind,ut1_unix = h5toh5(p.path,p.kineticsec,p.startutc)
#%% convert
    dmcconvert(rawImgData,ut1_unix,rawind,p.output,params)
#%% plots and save
    try:
        from matplotlib.pyplot import show
        doPlayMovie(rawImgData,p.movie, ut1_unix=ut1_unix,clim=p.clim)
        doplotsave(p.path,rawImgData,rawind,p.clim,p.hist,p.avg)
        show()
    except Exception as e:
        print('skipped plotting  {}'.format(e))