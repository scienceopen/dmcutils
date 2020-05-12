# DMC Utils

[![Zenodo](https://zenodo.org/badge/DOI/10.5281/zenodo.241127.svg)](https://zenodo.org/record/241127)

[![Travis CI](https://travis-ci.org/space-physics/dmcutils.svg?branch=master)](https://travis-ci.org/space-physics/dmcutils)
[![pypi versions](https://img.shields.io/pypi/pyversions/dmcutils.svg)](https://pypi.python.org/pypi/dmcutils)
[![PyPi Download stats](http://pepy.tech/badge/dmcutils)](http://pepy.tech/project/dmcutils)

Programs used to help with the Dual-Multi-sCale (DMC) experiment.
Example of dealing with 100000 - 1 million Andor Neo spool files in a fast way.

## Installation

    python -m pip install -e .

## Functions

* `angledist` computes angular distance between points (in degrees)
    for a pair of points with RA,decl. or az,el.

## Notes

[Install Matlab Engine](https://www.scivision.dev/matlab-engine-callable-from-python-how-to-install-and-setup/)
optional, just for corrupted 2010 Solis files.

---

The Andor Solis Neo spool file format has changed at least three times.
This spool reader is known to work for the 2011-2012 versions (I don't have exact version numbers, but could find out if you need).

For 2008-Spring 2011 spool files, see the `andor_neo_spool` directory in this repo.
