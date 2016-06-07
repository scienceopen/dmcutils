#!/usr/bin/env python
from setuptools import setup
import subprocess

#%%
try:
    subprocess.call(['conda','install','--yes','--file','requirements.txt'])
except Exception as e:
    pass

with open('README.rst','r') as f:
	long_description = f.read()

setup(name='dmcutils',
      packages=['dmcutils'],
	  description='Utilities for working with DMC (dual multi camera) Andor Neo sCMOS data',
	  long_description=long_description,
	  author='Michael Hirsch',
	  url='https://github.com/scienceopen/dmcutils',
      dependency_links = ['https://github.com/scienceopen/histutils/tarball/master#egg=histutils',
                          'https://github.com/scienceopen/astrometry_azel/tarball/master#egg=astrometry_azel'],
	  install_requires=['histutils','astrometry_azel'],
      extras_require={'flask':'flask','fl':'flask-limiter'},
	  )

