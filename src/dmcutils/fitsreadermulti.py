#!/usr/bin/env python
"""
reads multiple fits files and concatenates (consider your available RAM!)
"""
from typing import List
import logging
from pathlib import Path
from astropy.io import fits
from numpy import empty, nan

#
from histutils.rawDMCreader import getNeoParam
from histutils import setupimgh5, imgwriteincr


def fitsreadermulti(flist: List[Path], outfn: Path) -> tuple:

    outfn = Path(outfn).expanduser()
    flist = [Path(f).expanduser() for f in flist]
    # %% get size of each image
    with fits.open(flist[0], "readonly") as f:
        # no .ndim in astropy.io.fits 1.2
        assert (
            len(f[0].shape) == 3
        ), "i expect multiple images per file. Trivial change to one image per file"
        Y, X = f[0].shape[-2:]
        header = dict(f[0].header)
    # %% find total number of frames in all specified files
    nframetotal = 0
    for f in flist:
        try:
            with fits.open(f, "readonly") as h:
                nframetotal += h[0].shape[0]
                # be sure all files the same image size
                assert X == h[0].shape[2]
                assert Y == h[0].shape[1]
        except Exception as e:
            logging.error(f"{e}    Skipped {f}")

    if nframetotal * X * Y * 2 > 8e9:
        logging.warning("consuming more than 8GB RAM")
    # %%
    setupimgh5(outfn, nframetotal, Y, X, writemode="w")

    ut1_unix = empty(nframetotal)
    ut1_unix.fill(nan)

    lastframe = 0
    for f in flist:
        print("reading", f)
        try:
            with fits.open(f, "readonly") as h:
                N = h[0].shape[0]

                finf = getNeoParam(f)
                ut1_unix[lastframe : lastframe + N] = finf["ut1"]

                imgwriteincr(outfn, h[0].data, slice(lastframe, lastframe + N))

                lastframe += N

        except Exception as e:
            logging.warning(f"{e}   Skipped {f}")

    return ut1_unix, finf["frameind"], finf["kineticsec"], header
