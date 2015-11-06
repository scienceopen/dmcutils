#!/usr/bin/env python3
"""
Michael Hirsch
Sept 2015
"""
from __future__ import division,absolute_import
#
from histutils.rawDMCreader import dmcconvert
from dmcutils.neospool import oldspool,h5toh5

if __name__ == "__main__":
    from os.path import isfile,isdir
    from argparse import ArgumentParser
    p = ArgumentParser(description='Andor Neo Spool reader, plotter, converter')
    p.add_argument('path',help='path containing 12-bit Neo spool files in broken format (2008-spring 2011)')
    p.add_argument('-p','--pix',help='nx ny  number of x and y pixels respectively',nargs=2,default=(2544,2160),type=int)
    p.add_argument('-b','--bin',help='nx ny  number of x and y binning respectively',nargs=2,default=(1,1),type=int)
    p.add_argument('-k','--kineticsec',help='kinetic rate of camera (sec)  = 1/fps',type=float)
    p.add_argument('--rotccw',help='rotate CCW value in 90 deg. steps',type=int,default=0)
    p.add_argument('--transpose',help='transpose image',action='store_true')
    p.add_argument('--flipud',help='vertical flip',action='store_true')
    p.add_argument('--fliplr',help='horizontal flip',action='store_true')
    p.add_argument('-s','--startutc',help='utc time of nights recording')
    p.add_argument('-o','--output',help='extract raw data into this file [h5,fits,mat]')
    p.add_argument('-v','--verbose',help='debugging',action='count',default=0)
    p.add_argument('--fire',help='fire filename')
    p = p.parse_args()

    params = {'kineticsec':p.kineticsec,'rotccw':p.rotccw,'transpose':p.transpose,
              'flipud':p.flipud,'fliplr':p.fliplr,'fire':p.fire}

    if isfile(p.path) and p.path.endswith('.h5'):
        print('writing metadata')
        rawind,ut1_unix = h5toh5(p.path,p.kineticsec,p.startutc)
    elif isdir(p.path):
        rawind,ut1_unix = oldspool(p.path,p.pix,p.bin,p.kineticsec,p.startutc,p.output)
    else:
        raise ValueError

    dmcconvert(None,ut1_unix,rawind,p.output,params)
