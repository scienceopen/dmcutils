%RunSimulPlay

clear 
close all
clc

ccd.stem = '/media/small/BigData/Imaging/2012-12-20/CCD/2012-12-20T22-48-34_frames_317600-1-339300.tif';
ccd.kineticSec = 0.02711; ccd.startUT = datenum([2012 12 21 1 12 04]);
cmos.stem = '/media/small/BigData/Imaging/2012-12-20/Neo/X109-8bitogv.tif';
cmos.kineticSec = 0.03030303; cmos.startUT =datenum([2012 12 21 1 17 43]);

both.pbFPS = 10;
both.simKineticSec = 0.1; %skips frames to speedup playback
both.reqStartUT = nan; 
both.reqStopUT = nan;
[ccd2,cmos2,both2]=simulPlay(ccd,cmos,both)