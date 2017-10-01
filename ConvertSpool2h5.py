#!/usr/bin/env python
"""
Michael Hirsch
Sept 2015

Streams data from  spool file input disk to HDF5 output disk (both USB HDD) at 35 MB/s. Did not attempt to optimize.

Example performance: 4128 spool files selected by Detect.py, each with 47 320x270 images  33.5 GB -> HDF5 21.6 GB compression=1 in 948.5 sec.
That's 35 MB/sec.

# Example for CV_ionosphere automatic auroral detection output
1. ./FileTick.py  z:\2017-04-04a\spool
2. ../cv_ionosphere/Detect.py z:\2017-04-0a\spool\index.h5 z:\2017-04-27\ dmc2017.ini -k 10
2a. (optional patch for bad detect) ../cv_ionosphere/PatchAuroraldet.py
3. ./ConvertSpool2h5.py z:\2017-04-04a\spool\index.h5 -det z:\2017-04-04a\auroraldet.h5

./ConvertSpool2h5.py ~/H/neo2012-12-25/spool_5/index.h5 -det ~/data/2012-12-25/auroraldet.h5 -o ~/data/2012-12-25/extracted.h5 -xy 320 270 -stride 648 -z 4
or to convert all spool files without regard to detections
./ConvertSpool2h5.py ~/H/neo2012-12-25/spool_5/index.h5 -o ~/data/2012-12-25/extracted.h5 -xy 320 270 -stride 648 -z 4
"""
import logging
from time import time
from sys import argv
from dateutil.parser import parse
from pathlib import Path
import h5py
from pandas import read_hdf
import numpy as np
#
from histutils import vid2h5
from dmcutils.neospool import oldspool,h5toh5, readNeoSpool,spoolparam

W = 51  # keep +/-  W/2 frames around detection

def converter(p):
    tic = time()

    P = {'kineticsec':p.kineticsec,'rotccw':p.rotccw,'transpose':p.transpose,
         'flipud':p.flipud,'fliplr':p.fliplr,'fire':p.fire,
             }

    path = Path(p.path).expanduser()

    if path.is_file() and path.suffix == '.h5' :
        with h5py.File(path, 'r') as f:
            tickfile = 'filetick' in f  # spool file index

        if tickfile:
            """
            1. read index file
            2. (optional) read detection file
            3. convert specified file to HDF5
            """
            spoolini = path.parent / 'acquisitionmetadata.ini'
            if p.startutc is None:
                tstart = spoolini.stat().st_ctime  # crude measure of start time
            else:
                tstart = parse(p.startutc).timestamp()
            assert isinstance(tstart,(float,int))
# %% 1.
            flist = read_hdf(path,'filetick')
# %% 2. select which file to convert...automatically
            if p.detfn:
                detfn = Path(p.detfn).expanduser()
                with h5py.File(detfn,'r',libver='latest') as f:
                    det = f['/detect'][:]

                upfact = flist.shape[0] // det.size

                if not 1 <= upfact <= 20:
                    logging.error(f'was {detfn} sampled correctly?')
                    return

                det2 = np.zeros(flist.shape[0])
                try:
                    det2[:det.size*upfact-1:upfact] = det  # gaps are zeros
                except ValueError: # off by one
                    det2[:det.size*upfact:upfact] = det  # gaps are zeros

                assert abs(len(flist) - det2.size) <= 20,f'{detfn} and {path} are maybe not for the same spool data file directory'
                det = det2

                Lkeep = np.ones(min(len(flist),W),dtype=int)  # keeps Lkeep/2 files each side of first/last detection.

                ikeep = np.convolve(det,Lkeep,'same').astype(bool)
                det = det[ikeep]

                assert len(det) == ikeep.sum(),f'len(det): {len(det)}  ikeep.sum(): {ikeep.sum()}'
                assert len(ikeep)  == len(flist), f'len(flist): {len(flist)} len(ikeep): {len(ikeep)}'
            else:  # just convert all spool files (can be terabyte+ of data into HDF5)
                print('no detection file specified, converting all Spool files')
                det = np.ones(flist.shape[0],dtype=bool)
                ikeep = slice(None)
# %% 3.
            Fparam = spoolparam(spoolini,
                                p.xy[0]//p.bin[0], p.xy[1]//p.bin[1], p.stride)
            P = {**P,**Fparam}

            flist2 = flist[ikeep]
            print(f'keeping/converting {flist2.shape[0]} out of {flist.shape[0]} files in {path}')

            # append to HDF5 one spool file at a time to conserve RAM
            for i,fn in enumerate(flist2):
                fn = Path(path.parent/fn)
                P['spoolfn'] = fn
                imgs, ticks, tsec = readNeoSpool(fn, P, zerocols=p.zerocols)
                vid2h5(imgs, None, None, ticks, p.outfn, P, argv, i, len(flist2), det, tstart)
        else:
            print('writing metadata')
            rawind,ut1_unix = h5toh5(path, p.kineticsec, p.startutc)
            vid2h5(None, ut1_unix, rawind, p.outfn, P)
    elif p.broken:  # ancient spool file < 2011
        rawind,ut1_unix = oldspool(path, p.xy, p.bin, p.kineticsec, p.startutc, p.outfn)
        vid2h5(None, ut1_unix, rawind, p.outfn, P)
    else:
        raise ValueError('Not sure what to do with your specified options')

    print(f'wrote {p.outfn} in {time()-tic:.1f} sec.')

if __name__ == "__main__":
    from argparse import ArgumentParser
    p = ArgumentParser(description='Andor Neo Spool reader, plotter, converter')
    p.add_argument('path',help='path containing 12-bit Neo spool files in broken format (2008-spring 2011)')
    p.add_argument('-detfn',help='path to detections.h5 file')
    p.add_argument('-xy',help='nx ny  number of x and y pixels respectively',nargs=2,default=(2544,2160),type=int)
    p.add_argument('-b','--bin',help='nx ny  number of x and y binning respectively',nargs=2,default=(1,1),type=int)
    p.add_argument('-k','--kineticsec',help='kinetic rate of camera (sec)  = 1/fps',type=float)
    p.add_argument('--rotccw',help='rotate CCW value in 90 deg. steps',type=int,default=0)
    p.add_argument('--transpose',help='transpose image',action='store_true')
    p.add_argument('--flipud',help='vertical flip',action='store_true')
    p.add_argument('--fliplr',help='horizontal flip',action='store_true')
    p.add_argument('-s','--startutc',help='utc time of nights recording')
    p.add_argument('-o','--outfn',help='extract raw data into this file [h5,fits,mat]')
    p.add_argument('-v','--verbose',help='debugging',action='count',default=0)
    p.add_argument('-stride',help='length of footer in spool file',type=int)
    p.add_argument('-z','--zerocols',help='number of zero columns in spool file',type=int,default=8)
    p.add_argument('-fire',help='fire filename')
    p.add_argument('-broken',help='enables special Matlab reader for broken 2009-2010 spool files',action='store_true')
    p = p.parse_args()

    converter(p)
