#!/usr/bin/env python3
""" script to calibrate sCMOS data for 2013-01-13
assumes that https://github.com/scienceopen/astrometry is in adjacent directory ../astrometry
Michael Hirsch
"""
#from oct2py import Oct2Py
#from dateutil.parser import parse
from datetime import datetime,timedelta
from os.path import join,expanduser
import sys
sys.path.append('../astrometry')
#
from imgAvgfits import meanstack,writefits
from fits2azel import fits2azel

def calibrate(datadir,infn):
    #oc = Oct2Py(oned_as='column',timeout=5)
    #[ccd,cmos,both] = oc.RunSimulPlayFor2013Jan13('datadir',datadir,'play',False)
    #cmosStartUT = parse(oc.datestr(cmos['startUT']))
    Xfilenum = 38
    Xstartframe = 8300
    cmos = {'fullFileStart': datetime(2013, 1, 13, 21, 14, 34),
                 'framesPerFile':12427,
                 'kineticSec':0.03008434,
                 'latlon':(66.986330, -50.943941)}

    cmos['startUT'] = cmos['fullFileStart'] +  timedelta(seconds= (Xfilenum*cmos['framesPerFile'] + (Xstartframe-1))*cmos['kineticSec'] )
    print(cmos['startUT'])

    cmosfn = join(datadir,infn)
#%% convert to mean
    fitsfn=join(datadir,'cmosmean.fits')
    meanimg = meanstack(cmosfn,10)
    writefits(meanimg,fitsfn)

#%%
    x,y,ra,dec,az,el,timeFrame = fits2azel(fitsfn,cmos['latlon'],cmos['startUT'],['show','h5'],(0,2800))


if __name__ == '__main__':
    from argparse import ArgumentParser
    p = ArgumentParser(description='do plate scaling for 2013 Jan 13 CMOS data')
    p.add_argument('--datadir',help='directory where sCMOS data is',default='~/data')
    p.add_argument('--cmosfn',help='cmos data file name',default='neo2013-01-13_X38_frames8300-9500.tif')
    p = p.parse_args()

    calibrate(p.datadir,p.cmosfn)
