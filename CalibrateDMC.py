#!/usr/bin/env python3
""" script to calibrate sCMOS and CCD data for 2013-01-13
the CCD data was the first frame of irs_archive1/DMC/DataField/2012-11-22ccd.7z/spool.fits on our internal server.

Michael Hirsch
"""
from os.path import splitext
from tempfile import mkstemp
#
# REQUIRES https;//github.com/scienceopen/astrometry_azel
from astrometry_azel.imgAvgfits import meanstack,writefits
from astrometry_azel.fits2azel import fits2azel

def doplatescale(infn,outfn,latlon,ut1):
    if infn is None:
        return
    fitsfn = splitext(outfn)[0] + '.fits'
#%% convert to mean
    meanimg,ut1 = meanstack(infn,1,ut1)
    writefits(meanimg,fitsfn)
#%%
    x,y,ra,dec,az,el,timeFrame = fits2azel(fitsfn,latlon,ut1,['show','h5','png'],(0,2800))

if __name__ == '__main__':
    from argparse import ArgumentParser
    p = ArgumentParser(description='do plate scaling for 2013 Jan 13 CMOS data')
    p.add_argument('infn',help='image data file name')
    p.add_argument('-o','--outfn',help='platescale data file name to write',default=mkstemp('.h5')[1])
    p.add_argument('--latlon',help='wgs84 coordinates of cameras (deg.)',nargs=2,default=(66.986330, -50.943941),type=float)
    p.add_argument('--ut1',help='force UT1 time yyyy-mm-ddTHH:MM:SSZ')
    p = p.parse_args()

    doplatescale(p.infn,p.outfn,p.latlon,p.ut1)