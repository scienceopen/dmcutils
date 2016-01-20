#!/usr/bin/env python3
"""
converts multiple Andor Solis FITS files into one HDF5 with timestamps
watch RAM consumption
"""

from tempfile import mkstemp
from numpy import nan
#
from dmcutils.fitsreadermulti import fitsreadermulti
from histutils.rawDMCreader import dmcconvert

def main(flist,output,params,cmdlog):

    data,ut1_unix,rawind,kineticsec = fitsreadermulti(flist)

    params['kineticsec'] = kineticsec

    dmcconvert(data,ut1_unix,rawind,output,params,cmdlog)



if __name__ == '__main__':
    from sys import argv
    from argparse import ArgumentParser
    p = ArgumentParser(description='converts multiple Andor Solis FITS files into one HDF5 with timestamps')
    p.add_argument('flist',help='file(s) to convert to one HDF5 file',nargs='+')
    p.add_argument('-o','--output',help='extract raw data into this file [h5]',default=mkstemp('.h5')[1])
    p.add_argument('--rotccw',help='rotate CCW value in 90 deg. steps',type=int,default=0)
    p.add_argument('--transpose',help='transpose image',action='store_true')
    p.add_argument('--flipud',help='vertical flip',action='store_true')
    p.add_argument('--fliplr',help='horizontal flip',action='store_true')
    p.add_argument('-c','--coordinates',help='wgs84 coordinates of sensor (lat,lon,alt_m)',nargs=3,default=(nan,nan,nan),type=float)
    p = p.parse_args()

    params = {'rotccw':p.rotccw,'transpose':p.transpose,
              'flipud':p.flipud,'fliplr':p.fliplr,'sensorloc':p.coordinates}

    main(p.flist,p.output,params,' '.join(argv))


