#!/usr/bin/env python
from setuptools import setup
import subprocess

#%%
try:
    subprocess.call(['conda','install','--file','requirements.txt'])
except Exception as e:
    pass

setup(name='dmcutils',
      packages=['dmcutils'],
	  description='Utilities for working with DMC (dual multi camera) Andor Neo sCMOS data',
	  author='Michael Hirsch',
	  url='https://github.com/scienceopen/dmcutils',
      dependency_links = ['https://github.com/scienceopen/histutils/tarball/master#egg=histutils',
                          'https://github.com/scienceopen/astrometry_azel/tarball/master#egg=astrometry_azel',
                          'https://github.com/scienceopen/cvutils/tarball/master#egg=cvutils'],
	  install_requires=['histutils','astrometry_azel','cvutils',
                        'pathlib2'],
      extras_require={'flask':'flask','fl':'flask-limiter'},
	  )

