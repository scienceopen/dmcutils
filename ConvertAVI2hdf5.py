#!/usr/bin/env python
"""
converts AVI into HDF5 with timestamps
"""
from tempfile import mkstemp
from numpy import nan
#
from dmcutils.avi2hdf5 import avi2hdf5

if __name__ == '__main__':
    from sys import argv
    from argparse import ArgumentParser
    p = ArgumentParser(description='converts multiple Andor Solis FITS files into one HDF5 with timestamps')
    p.add_argument('avifn',help='AVI filename to convert to one HDF5 file')
    p.add_argument('-o','--ofn',help='extract raw data into this file [h5]',default=mkstemp('.h5')[1])
    p.add_argument('--rotccw',help='rotate CCW value in 90 deg. steps',type=int,default=0)
    p.add_argument('--transpose',help='transpose image',action='store_true')
    p.add_argument('--flipud',help='vertical flip',action='store_true')
    p.add_argument('--fliplr',help='horizontal flip',action='store_true')
    p.add_argument('-c','--coordinates',help='wgs84 coordinates of sensor (lat,lon,alt_m)',nargs=3,default=(nan,nan,nan),type=float)
    p.add_argument('--t0',help='start time YYYY-MM-DDTHH:mm:ss.fffZ')
    p.add_argument('--fps',help='frames/sec',type=float)
    p = p.parse_args()

    params = {'rotccw':p.rotccw,'transpose':p.transpose,
              'flipud':p.flipud,'fliplr':p.fliplr,'sensorloc':p.coordinates,
              'cmdlog':' '.join(argv)}

    if p.fps is not None:
        params['kineticsec'] = 1/p.fps
    else:
        params['kineticsec'] = None

    avi2hdf5(p.avifn, p.ofn, p.t0, params)


