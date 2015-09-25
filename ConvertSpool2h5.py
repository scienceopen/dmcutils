#!/usr/bin/env python3
"""
Michael Hirsch
Sept 2015
"""
from __future__ import division,absolute_import
from histutils.rawDMCreader import dmcconvert,doPlayMovie,doplotsave
from histutils.timedmc import frame2ut1,ut12frame

def goRead(fn,xy,bn,kineticsec,startutc):


if __name__ == "__main__":
    from argparse import ArgumentParser
    p = ArgumentParser(description='Andor Neo Spool reader, plotter, converter')
    p.add_argument('infile',help='.DMCdata file name and path')
    p.add_argument('-p','--pix',help='nx ny  number of x and y pixels respectively',nargs=2,default=(512,512),type=int)
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

    rawImgData,rawind,finf,ut1_unix = goRead(p.infile, p.pix,p.bin,p.kineticsec,p.startutc)
#%% convert
    dmcconvert(finf,p.infile,rawImgData,ut1_unix,rawind,p.output,params)
#%% plots and save
    try:
        from matplotlib.pyplot import show
        doPlayMovie(rawImgData,p.movie, ut1_unix=ut1_unix,clim=p.clim)
        doplotsave(p.infile,rawImgData,rawind,p.clim,p.hist,p.avg)
        show()
    except Exception as e:
        print('skipped plotting  {}'.format(e))