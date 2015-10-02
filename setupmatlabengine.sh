#!/bin/sh

(
cd /usr/local/MATLAB/R2015b/extern/engines/python/
sudo ~/anaconda$1/bin/python setup.py install

)
