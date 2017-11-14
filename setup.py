#!/usr/bin/env python
req=['nose','python-dateutil','pytz','pandas','h5py','scikit-image',
     'histutils','morecvutils']
# %%
from setuptools import setup

setup(name='dmcutils',
      packages=['dmcutils'],
      author='Michael Hirsch, Ph.D.',
      url='https://github.com/scivision/dmcutils',
      description='Utilities to read and plot DMC Experiment data',
      version='0.9',
	  install_requires=req,
	  python_requires='>=3.6',
      extras_require={'web':['flask','flask-limiter'],
                      'plot':['matplotlib'],
                      'io':['astrometry_azel'],},
	  )

