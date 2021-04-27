#!/usr/bin/env python
"""
converts multiple Andor Solis FITS files into one HDF5 with timestamps
watch RAM consumption
"""
from pathlib import Path
from typing import List
from numpy import nan

#
from dmcutils.fitsreadermulti import fitsreadermulti
from histutils import vid2h5


def main(flist: List[Path], ofn: Path, P: dict):

    ut1_unix, rawind, kineticsec, header = fitsreadermulti(flist, ofn)

    P["kineticsec"] = kineticsec
    P["header"] = header

    vid2h5(None, ut1_unix, rawind, None, ofn, P)


if __name__ == "__main__":
    from sys import argv
    from argparse import ArgumentParser

    p = ArgumentParser(
        description="converts multiple Andor Solis FITS files into one HDF5 with timestamps"
    )
    p.add_argument("flist", help="file(s) to convert to one HDF5 file", nargs="+")
    p.add_argument("ofn", help="extract raw data into this file [h5]")
    p.add_argument("--rotccw", help="rotate CCW value in 90 deg. steps", type=int, default=0)
    p.add_argument("--transpose", help="transpose image", action="store_true")
    p.add_argument("--flipud", help="vertical flip", action="store_true")
    p.add_argument("--fliplr", help="horizontal flip", action="store_true")
    p.add_argument(
        "-c",
        "--coordinates",
        help="wgs84 coordinates of sensor (lat,lon,alt_m)",
        nargs=3,
        default=(nan, nan, nan),
        type=float,
    )
    P = p.parse_args()

    Pm = {
        "rotccw": P.rotccw,
        "transpose": P.transpose,
        "flipud": P.flipud,
        "fliplr": P.fliplr,
        "sensorloc": P.coordinates,
        "cmdlog": " ".join(argv),
    }

    main(P.flist, P.ofn, Pm)
