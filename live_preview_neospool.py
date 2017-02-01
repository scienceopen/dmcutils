#!/usr/bin/env python
from dmcutils.neospool import findnewest,readNeoSpool,mean16to8,annowrite

if __name__ == '__main__':
    from argparse import ArgumentParser
    p = ArgumentParser(description='find newest file in directory, take mean of images, convert to PNG for web live preview')
    p.add_argument('path',help='path to search')
    p.add_argument('--inifile',help='filename to parse to get basic image shape parameters',default='acquisitionmetadata.ini')
    p.add_argument('-o','--outpath',help='path to write the live png image to',default='html/latest.png')
    p = p.parse_args()
#%% find newest file to extract images from
    newfn = findnewest(p.path)
#%% read images and FPGA tick clock from this file
    frames,ticks = readNeoSpool(newfn,p.inifile)
#%% 16 bit to 8 bit, mean of image stack for this file
    f8bit = mean16to8(frames)
#%% put time on image and write to disk
    annowrite(f8bit,newfn,p.outpath)
