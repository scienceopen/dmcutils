#!/usr/bin/env python
from pathlib import Path
from scipy.ndimage import imread
from dmcutils.neospool import findnewest,readNeoSpool,mean16to8,annowrite

if __name__ == '__main__':
    from argparse import ArgumentParser
    p = ArgumentParser(description='find newest file in directory, take mean of images, convert to PNG for web live preview')
    p.add_argument('path',help='path to search')
    p.add_argument('--inifile',help='filename to parse to get basic image shape parameters',default='acquisitionmetadata.ini')
    p.add_argument('-o','--outpath',help='path to write the live png image to',default='html/latest.png')
    p = p.parse_args()

    root = Path(p.path).expanduser()
    
    if root.is_file() or (root/'image.bmp').is_file():
        f8bit = imread(root) # TODO check for 8 bit
    elif root.is_dir():
#%% find newest file to extract images from
        newfn = findnewest(root)
#%% read images and FPGA tick clock from this file
        frames,ticks = readNeoSpool(newfn,p.inifile)
#%% 16 bit to 8 bit, mean of image stack for this file
        f8bit = mean16to8(frames)
    else:
        raise ValueError(f'unknown image file/location {root}')

#%% put time on image and write to disk
    annowrite(f8bit,newfn,p.outpath)
