#!/usr/bin/env python
""" script to calibrate sCMOS and CCD data for 2013-01-13
the CCD data was the first frame of irs_archive1/DMC/DataField/2012-11-22ccd.7z/spool.fits on our internal server.

can accept input files in .h5 .fits and more

Michael Hirsch
"""
from pathlib import Path
from tempfile import mkstemp
#
# REQUIRES https://github.com/scienceopen/astrometry_azel
from astrometry_azel.imgAvgStack import meanstack,writefits
from astrometry_azel.fits2azel import fits2azel

def doplatescale(infn,outfn,latlon,ut1):
    fitsfn = Path(outfn).expanduser().with_suffix('.fits')
#%% convert to mean
    meanimg,ut1 = meanstack(infn,10,ut1)
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
