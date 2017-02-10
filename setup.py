#!/usr/bin/env python
from setuptools import setup

req=['histutils','astrometry_azel','cvutils',
     'nose','python-dateutil','pytz','pandas','h5py','scikit-image','matplotlib']

setup(name='dmcutils',
      packages=['dmcutils'],
      author='Michael Hirsch, Ph.D.',
      url='https://github.com/scienceopen/dmcutils',
      description='Utilities to read and plot DMC Experiment data',
      version='0.9',
      dependency_links = ['https://github.com/scienceopen/cvutils/tarball/master#egg=cvutils'],
	  install_requires=req,
      extras_require={'flask':'flask','fl':'flask-limiter'},
	  )

