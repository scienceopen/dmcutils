#!/usr/bin/env python
from dmcutils.neospool import preview_newest


if __name__ == '__main__':
    from argparse import ArgumentParser
    p = ArgumentParser(description='find newest file in directory, take mean of images, convert to JPG for web live preview')
    p.add_argument('path',help='path to search')
    p.add_argument('-o','--outpath',help='path to write the live png image to',default='static/latest.jpg')
    p.add_argument('--inifn',help='metadata ini',default='acquisitionmetadata.ini')
    p.add_argument('-v','--verbose',action='store_true')
    p = p.parse_args()


    fset = preview_newest(p.path,p.outpath,p.inifn,p.verbose)
