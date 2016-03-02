#!/usr/bin/env python3
"""
reads multiple fits files and concatenates (consider your available RAM!)
"""
import logging
from pathlib import Path
from astropy.io import fits
from numpy import zeros,uint16,empty,nan
#
from histutils.rawDMCreader import getNeoParam
from .h5imgwriter import setupimgh5,imgwriteincr

def fitsreadermulti(flist,outfn):

    outfn = Path(outfn).expanduser()
    flist = [Path(f).expanduser() for f in flist]

    with fits.open(str(flist[0]),'readonly') as h:
        X,Y = h[0].header['NAXIS1'], h[0].header['NAXIS2']

    nframetotal = 0


    for f in flist:
        try:
            with fits.open(str(f),'readonly') as h:
                nframetotal += h[0].header['NAXIS3']
                #be sure all files the same image size
                assert(X==h[0].header['NAXIS1'])
                assert(Y==h[0].header['NAXIS2'])
        except Exception as e:
            logging.error('{}    Skipped {}'.format(e,f))

    if nframetotal*X*Y*2 > 8e9:
        logging.warning('consuming more than 8GB RAM')
#%%
    setupimgh5(outfn,nframetotal,Y,X)

    ut1_unix = empty(nframetotal);  ut1_unix.fill(nan)


    lastframe = 0
    for f in flist:
        try:
            with fits.open(str(f),'readonly') as h:
                N = h[0].header['NAXIS3']

                finf = getNeoParam(f)[0]
                ut1_unix[lastframe:lastframe+N] = finf['ut1']

                imgwriteincr(outfn,h[0].data,slice(lastframe,lastframe+N))

                lastframe += N

        except Exception as e:
            logging.warning('{}   Skipped {}'.format(e,f))

    return ut1_unix,finf['frameind'],finf['kineticsec']