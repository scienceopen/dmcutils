=========
dmcutils
=========

Programs used to help with the Dual-Multi-sCale (DMC) experiment.
Example of dealing with 100000 - 1 million Andor Neo spool files in a fast way.

.. contents::

Installation
============
::

    pip install -e .

Functions
=========
* ``angledist`` computes angular distance between points (in degrees) for a pair of points with RA,decl. or az,el.

Caveats
=======
The Andor Solis Neo spool file format has changed at least three times. This spool reader is known to work for the 2011-2012 versions (I don't have exact version numbers, but could find out if you need).

For 2008-Spring 2011 spool files, see the ``andor_neo_spool`` directory in this repo.

Experiments:
============

**2013 Jan 13** great example, run in Octave 4.0+ or Matlab
``RunSimulPlayFor2013Jan13`` to show simultaneous video from cameras

-datadir       path to data files
-writevid      filename to write to (uncompressed AVI)

Install Matlab Engine
=====================

https://www.scivision.co/matlab-engine-callable-from-python-how-to-install-and-setup/


