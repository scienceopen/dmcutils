#!/usr/bin/env python
from pathlib import Path
from scipy.ndimage import imread
#
from dmcutils import mean16to8
from dmcutils.neospool import findnewest,readNeoSpool,annowrite,spoolparam

INIFN = 'acquisitionmetadata.ini'

if __name__ == '__main__':
    from argparse import ArgumentParser
    p = ArgumentParser(description='find newest file in directory, take mean of images, convert to JPG for web live preview')
    p.add_argument('path',help='path to search')
    p.add_argument('-o','--outpath',help='path to write the live png image to',default='static/latest.jpg')
    p = p.parse_args()

    root = Path(p.path).expanduser()

    if (root/'image.bmp').is_file():
        f8bit = imread(root/'image.bmp') # TODO check for 8 bit
    elif root.is_dir(): # spool case
#%% find newest file to extract images from
        newfn = findnewest(root)
#%% read images and FPGA tick clock from this file
        P = spoolparam(newfn.parent/INIFN)
        frames,ticks,tsec = readNeoSpool(newfn, P)
#%% 16 bit to 8 bit, mean of image stack for this file
        f8bit = mean16to8(frames)
    else:
        raise ValueError(f'unknown image file/location {root}')

#%% put time on image and write to disk
    annowrite(f8bit, newfn, p.outpath)
