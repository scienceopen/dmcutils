%RunSimulPlay

clear 
close all
clc

both.pbFPS = 20;
both.simKineticSec = 0.05; %skips frames to speedup playback
both.reqStartUT = nan;%datenum([2012 12 21 1 20 20]); 
both.reqStopUT = nan;

%rotate CCD data 90 degrees clockwise?
ccd.rot90cw = true;

%rotate CMOS data 90 degrees COUNTERclockwise?
cmos.rot90ccw = true;

% data number scaling
ccd.minVal = 1000; %baseline of CCD is 1000 (lowest data number)
ccd.maxVal = 4000;

cmos.minVal = 0; %these are relative values, since data had to be downloaded as 8-bit to save internet bandwidth
cmos.maxVal = 255;
display('CMOS intensities here are relative!')

ccd.stem = '2012-12-20T22-48-34_frames_317600-1-339300.tif';
ccd.kineticSec = 0.02711; ccd.startUT = datenum([2012 12 21 1 12 04]);

cmos.stem{1} = 'X105full.tif';
cmos.kineticSec = 0.03030303; cmos.startUT =datenum([2012 12 21 1 13 00]);

cmos.stem{2} = 'X106full.tif';
%cmos.kineticSec = 0.03030303; cmos.startUT =datenum([2012 12 21 1 14 34]);

cmos.stem{3} = 'X107full.tif';
%cmos.kineticSec = 0.03030303; cmos.startUT =datenum([2012 12 21 01 16 08]);

cmos.stem{4} = 'X108full.tif';
%cmos.kineticSec = 0.03030303; cmos.startUT =datenum([2012 12 21 01 17 43]);

cmos.stem{5} = 'X109full.tif';
%cmos.kineticSec = 0.03030303; cmos.startUT =datenum([2012 12 21 1 19 17]);


[ccd2,cmos2,both2]=simulPlay(ccd,cmos,both);