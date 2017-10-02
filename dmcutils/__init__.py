from pathlib import Path
import shutil
import h5py
import numpy as np
from scipy.misc import bytescale
#
from histutils.timedmc import frame2ut1

def write_quota(outbytes, outfn:Path):
    """
    aborts writing if not enough space on drive to write
    """

    if outfn:
        freeout = shutil.disk_usage(outfn.parent).free
        if freeout < 10*outbytes:
            raise RuntimeError(f'out of disk space on {outfn.parent}.  {freeout/1e9} GB free, wanting to write {outsize/1e9} GB.')


def h5toh5(fn,kineticsec,startutc):
    """
    determine UTC time of each frame and index of each frame
    """
    fn = Path(fn).expanduser()

    with h5py.File(fn, 'r', libver='latest') as f:
        data = f['/rawimg']

        rawind = np.arange(data.shape[0])+1

    ut1 = frame2ut1(startutc,kineticsec,rawind)

    return rawind, ut1


def mean16to8(I):
#%% take mean and scale images
    fmean = I.mean(axis=0)
    l,h = np.percentile(fmean, (0.5,99.5))
#%% 16 bit to 8 bit using scikit-image
    return bytescale(fmean, cmin=l, cmax=h)