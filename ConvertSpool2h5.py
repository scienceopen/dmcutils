#!/usr/bin/env python
"""
Michael Hirsch
Sept 2015
"""
from dmcutils import Path
#
from histutils.vid2h5 import vid2h5
from dmcutils.neospool import oldspool,h5toh5

if __name__ == "__main__":
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

    path = Path(p.path).expanduser()

    if path.is_file() and path.suffix == '.h5':
        print('writing metadata')
        rawind,ut1_unix = h5toh5(path,p.kineticsec,p.startutc)
    elif path.is_dir():
        rawind,ut1_unix = oldspool(path,p.pix,p.bin,p.kineticsec,p.startutc,p.output)
    else:
        raise FileNotFoundError(path)

    vid2h5(None,ut1_unix,rawind,p.output,params)
