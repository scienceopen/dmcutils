#!/usr/bin/env python
from setuptools import setup

try:
    import conda.cli
    conda.cli.main('install','--file','requirements.txt')
except Exception as e:
    print(e)

setup(name='dmcutils',
      packages=['dmcutils'],
      dependency_links = ['https://github.com/scienceopen/histutils/tarball/master#egg=histutils',
                          'https://github.com/scienceopen/astrometry_azel/tarball/master#egg=astrometry_azel',
                          'https://github.com/scienceopen/cvutils/tarball/master#egg=cvutils'],
	  install_requires=['histutils','astrometry_azel','cvutils',],
      extras_require={'flask':'flask','fl':'flask-limiter'},
	  )

