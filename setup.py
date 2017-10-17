#!/usr/bin/env python
req=['nose','python-dateutil','pytz','pandas','h5py','scikit-image','matplotlib']
pipreq=['tables','histutils','astrometry_azel','morecvutils']
     
import pip
try:
    import conda.cli
    conda.cli.main('install',*req)
except Exception as e:
    pip.main(['install']+req)
pip.main(['install']+pipreq)
# %%
from setuptools import setup

setup(name='dmcutils',
      packages=['dmcutils'],
      author='Michael Hirsch, Ph.D.',
      url='https://github.com/scivision/dmcutils',
      description='Utilities to read and plot DMC Experiment data',
      version='0.9',
	  install_requires=req+pipreq,
      extras_require={'flask':['flask'],'fl':['flask-limiter']},
	  )

