#!/bin/sh

(
cd /usr/local/MATLAB/R2015a/extern/engines/python/
sudo ~/anaconda$1/bin/python setup.py install

)
