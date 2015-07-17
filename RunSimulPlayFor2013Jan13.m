%RunSimulPlay

%requires Neo data to be one multi-page TIFF
% and CCD data to be raw .DMCdata

clear 
close all
clc

dataDir = '~/data/';

day2sec = 86400;
both.pbFPS = 20;
both.simKineticSec = 0.06; %skips frames to speedup playback
both.reqStartUT = nan;%datenum([2013 1 13 1 15 35]); 
both.reqStopUT = nan;

%rotate CCD data 90 degrees clockwise?
ccd.rot90cw = false;


%rotate CMOS data 90 degrees clockwise?
cmos.rot90cw = true;


% data number scaling
ccd.minVal = 980; %baseline of CCD is 1000 (lowest data number)
ccd.maxVal = 3400;
ccd.stem = [dataDir,'/2013-01-13T21-00-00_frames_562000-1-568000.DMCdata'];
ccd.kineticSec = 0.02711; 
ccd.fullFileStart = datenum([2013 01 13 21 00 00]);
ccd.startUT = ccd.fullFileStart + (562000-1)*ccd.kineticSec/day2sec;

cmos.minVal = 0; 
cmos.maxVal = 1000;
cmos.stem = {[dataDir,'/neo2013-01-13_X38_frames8300-9500.tif']}; %must be a cell
cmos.kineticSec = 0.03008434; 
cmos.fullFileStart = datenum([2013 01 13 21 14 34]);
cmos.framesPerFile = 12427;
%remember, CMOS FITS files are named zero-indexed!
cmos.startUT =cmos.fullFileStart + ...
    ((38*cmos.framesPerFile + (8300-1))*cmos.kineticSec )/day2sec;


[ccd2,cmos2,both2]=simulPlay(ccd,cmos,both);
