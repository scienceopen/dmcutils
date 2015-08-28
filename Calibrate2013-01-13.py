#!/usr/bin/env python3
""" script to calibrate sCMOS data for 2013-01-13
Michael Hirsch
"""
#from oct2py import Oct2Py
#from dateutil.parser import parse
from datetime import datetime,timedelta
from os.path import join,split
#
# REQUIRES https;//github.com/scienceopen/astrometry_azel
from astrometry_azel.imgAvgfits import meanstack,writefits
from astrometry_azel.fits2azel import fits2azel

def calibrate(infn):
    Xfilenum = 38
    Xstartframe = 8300
    cmos = {'fullFileStart': datetime(2013, 1, 13, 21, 14, 34),
                 'framesPerFile':12427,
                 'kineticSec':0.03008434,
                 'latlon':(66.986330, -50.943941)}

    cmos['startUT'] = cmos['fullFileStart'] +  timedelta(seconds= (Xfilenum*cmos['framesPerFile'] + (Xstartframe-1))*cmos['kineticSec'] )
    print(cmos['startUT'])

    datadir = split(infn)[0]
#%% convert to mean
    fitsfn=join(datadir,'cmosmean.fits')
    meanimg = meanstack(infn,10)
    writefits(meanimg,fitsfn)

#%%
    x,y,ra,dec,az,el,timeFrame = fits2azel(fitsfn,cmos['latlon'],cmos['startUT'],['show','h5','png'],(0,2800))


if __name__ == '__main__':
    from argparse import ArgumentParser
    p = ArgumentParser(description='do plate scaling for 2013 Jan 13 CMOS data')
    p.add_argument('cmosfn',help='cmos data file name')
    p = p.parse_args()

    calibrate(p.cmosfn)
