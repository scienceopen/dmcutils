#!/usr/bin/env python3
""" script to calibrate sCMOS data for 2013-01-13
assumes that https://github.com/scienceopen/astrometry is in adjacent directory ../astrometry
Michael Hirsch
"""
from oct2py import Oct2Py

oc = Oct2Py(oned_as='column',convert_to_float=True,timeout=5)

def calibrate(datadir):
    [ccd,cmos,both] = oc.RunSimulPlayFor2013Jan13('datadir',datadir,'play',False)
    print(cmos['startUT'])

if __name__ == '__main__':
    from argparse import ArgumentParser
    p = ArgumentParser(description='do plate scaling for 2013 Jan 13 CMOS data')
    p.add_argument('--datadir',help='directory where sCMOS data is',default='~/data')
    p = p.parse_args()

    calibrate(p.datadir)
