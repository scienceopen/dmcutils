#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Assumes observing from 66.986330° N, 50.943941° W.  I did not take into account slight ground distance between camera and radar.
E-region magnetic zenith at 79.7213° el, 150.11° az clockwise from geographic north.
But the beam was pointed at F-region magnetic zenith?

Sondrestrom ISR was pointing at 80.55 el, 141.0 az from 23:03:48 to 23:06:36
"""
from pathlib import Path
from os import devnull
from datetime import datetime
from numpy import empty, ones, unravel_index, percentile
from numpy.ma import masked_where
import h5py
from matplotlib.pyplot import figure, draw, pause, subplots, show
from matplotlib.colors import LogNorm
from matplotlib.dates import DateFormatter
import matplotlib.animation as anim
from pymap3d.haversine import angledist
import seaborn as sns

sns.set_context("talk", font_scale=1.5)

calfn = "cal/DMC2015-11.h5"
# magneticzenithazel = (150.11,79.7213) #degrees  E-region
SondrestromFWHM = 0.5  # degrees
# %%


def plotstats(bmean, bmin, bmax, bvar, t, imgfn, israzel, isrvalid):

    fg, ax = subplots(4, 1, sharex=True)
    tse = " ".join([t.strftime("%X") for t in isrvalid])
    fg.suptitle("{} az,el {} time: {}".format(imgfn, israzel, tse))

    ax[0].plot(t, bmean)
    ax[0].set_ylabel("mean")

    ax[1].plot(t, bmin)
    ax[1].set_ylabel("min")

    ax[2].plot(t, bmax)
    ax[2].set_ylabel("max")

    ax[3].plot(t, bvar)
    ax[3].set_ylabel("variance")
    ax[3].set_xlabel("estimated time [UTC]")

    for a in ax:
        a.set_yscale("log")
        a.grid(True, which="x")
        a.xaxis.set_major_formatter(DateFormatter("%H:%M:%S"))

    fg.autofmt_xdate()
    fg.tight_layout()


def loadplot(imgfn, calfn, israzel, isrvalid, showmovie, writemovie):
    imgfn = Path(imgfn).expanduser()
    calfn = Path(calfn).expanduser()
    # %% indices corresponding to the sondestrom beam
    with h5py.File(str(calfn), "r", libver="latest") as h:
        az = h["az"][:]
        el = h["el"][:]
        dang = angledist(israzel[0], israzel[1], az, el)
        mask = dang < SondrestromFWHM
        boresight_rc = unravel_index(dang.argmin(), az.shape)
    Npixmask = mask.sum()
    print("found {} pixels in Sondrestrom ISR beam".format(Npixmask))
    if Npixmask == 0:
        raise ValueError("No overlap of radar beam with camera FOV")

    # %% ingest images
    tvalid = [t.timestamp() for t in isrvalid]
    with h5py.File(str(imgfn), "r", libver="latest") as h:
        uts = h["ut1_unix"][:]
        utind = (tvalid[0] <= uts) & (uts <= tvalid[1])

        print("loading image data into RAM")
        imgs = h["rawimg"][utind, ...]
        Nimg = imgs.shape[0]
        print("{} images loaded from {}".format(Nimg, imgfn))
        # %% Statistics of image pixels corresponding to ISR beam
        t = [datetime.utcfromtimestamp(ut) for ut in uts[utind]]
        # %% plotting

        if showmovie or writemovie:
            Writer = anim.writers["ffmpeg"]
            writer = Writer(fps=5, metadata={"artist": "Michael Hirsch"}, codec="ffv1")
            if writemovie:
                ofn = imgfn.rsplit(".", 1)[0] + ".mkv"

            else:
                ofn = devnull

            fg = figure()
            ax = fg.gca()

            vlim = percentile(imgs, (2, 99.9))

            hi = ax.imshow(imgs[0, ...], cmap="gray", norm=LogNorm(), origin="lower", vmin=vlim[0], vmax=vlim[1])  # primes display
            fg.colorbar(hi)

            mim = masked_where(~mask, ones(imgs.shape[1:]))
            ax.imshow(mim, cmap="bwr", alpha=0.15, vmin=0, vmax=1, origin="lower")  # radar beam
            ax.set_xlabel("x-pixel")
            ax.set_ylabel("y-pixel")

            ax.scatter(boresight_rc[1], boresight_rc[0], s=150, marker="*", alpha=0.3, color="b")

            c = ax.contour(az, colors="w", alpha=0.1)
            ax.clabel(c, inline=1, fmt="%0.1f")
            c = ax.contour(el, colors="w", alpha=0.1)
            ax.clabel(c, inline=1, fmt="%0.1f")

            ht = ax.set_title("", color="g")
            ax.grid(False)

        if showmovie or writemovie:
            with writer.saving(fg, str(ofn), 150):
                bmean, bmin, bmax, bvar = update(imgs, mask, t, hi, ht, showmovie, writemovie, writer)
        else:
            bmean, bmin, bmax, bvar = update(imgs, mask, t, None, None, showmovie, writemovie, None)

        plotstats(bmean, bmin, bmax, bvar, t, imgfn, israzel, isrvalid)


def update(imgs, mask, t, hi, ht, showmovie, writemovie, writer):
    Nimg = imgs.shape[0]
    bmean = empty(Nimg)
    bmin = empty(Nimg)
    bmax = empty(Nimg)
    bvar = empty(Nimg)

    for i, img in enumerate(imgs):
        im = img[mask]
        bmean[i] = im.mean()
        bmin[i] = im.min()
        bmax[i] = im.max()
        bvar[i] = im.var()

        if showmovie or writemovie:
            hi.set_data(img)
            ht.set_text("{}".format(t[i]))
            draw(), pause(0.001)
            if writemovie:
                writer.grab_frame(facecolor="k")

    return bmean, bmin, bmax, bvar


if __name__ == "__main__":
    from argparse import ArgumentParser

    p = ArgumentParser()
    p.add_argument(
        "-s", "--showmovie", help="show live movie (takes a while, don't use if you want quick summary plot", action="store_true"
    )
    p.add_argument(
        "-w",
        "--writemovie",
        help="write a LOSSLESS movie file that is viewable on phones, etc. easily from the HDF5 file",
        action="store_true",
    )
    P = p.parse_args()

    if 0:  # juha 11-14
        imgfn = "~/data/2015-11-14/2015-11-14T0149-0202.h5"
        israzel = (141.0, 80.55)
        isrvalid = (datetime(2015, 11, 14, 1, 55, 9), datetime(2015, 11, 14, 1, 55, 49))
    if 0:  # juha 11-15
        imgfn = "~/data/2015-11-15/2015-11-15T2304-2306.h5"
        israzel = ((141.0, 80.55),)  # (321.,89.5)
        isrvalid = (datetime(2015, 11, 15, 23, 3, 48), datetime(2015, 11, 15, 23, 6, 36))
    if 1:  # asti
        imgfn = "~/data/2015-11-15/2015-11-15T2318-2320.h5"
        israzel = (141.0, 80.55)
        isrvalid = (datetime(2015, 11, 15, 23, 18, 5), datetime(2015, 11, 15, 23, 19, 53))

    loadplot(imgfn, calfn, israzel, isrvalid, P.showmovie, P.writemovie)

    show()
