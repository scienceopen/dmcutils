from pathlib import Path
import h5py
import numpy as np
import typing as T

#
from histutils.timedmc import frame2ut1


def h5toh5(fn: Path, kineticsec: float, startutc):
    """
    determine UTC time of each frame and index of each frame
    """
    fn = Path(fn).expanduser()

    with h5py.File(fn, "r", libver="latest") as f:
        data = f["/rawimg"]

        rawind = np.arange(data.shape[0]) + 1

    ut1 = frame2ut1(startutc, kineticsec, rawind)

    return rawind, ut1


def mean16to8(img: np.ndarray) -> np.ndarray:
    """

    Parameters
    ----------
    img: uint16 ndarray image

    Results
    -------
    uint8 ndarray

    1. take mean of uint16 image stack
    2. clip off extrema (very dim or bright)
    3. return uint8 image
    """
    fmean = img.mean(axis=0)
    ln, h = np.percentile(fmean, (0.5, 99.5))
    # %% 16 bit to 8 bit using scikit-image
    return bytescale(fmean, (ln, h))


def bytescale(img: np.ndarray, Clim: T.Tuple[int, int]) -> np.ndarray:
    """
    stretch uint16 data to uint8 data e.g. images
    Parameters
    ----------
    img: numpy.ndarray
        2-D Numpy array of grayscale image data
    Clim: tuple of int
        lowest and highest expected values
    """
    # stretch to [0,255] as a float
    Q = normframe(img, Clim) * 255

    return Q.astype(np.uint8)  # convert to uint8


def normframe(img: np.ndarray, Clim: T.Tuple[int, int]) -> np.ndarray:
    """
    Normalize array to [0, 1]
    Parameters
    ----------
    img: numpy.ndarray
        data to be normalized
    Clim: tuple of int
        lowest and highest expected values
    """
    Vmin = Clim[0]
    Vmax = Clim[1]

    return (img.astype(np.float32).clip(Vmin, Vmax) - Vmin) / (Vmax - Vmin)
