%% RunSimulPlay
% Michael Hirsch 2013
% requires Octave 4.0+ or Matlab
% plays CCD and CMOS video time-synched
%
% requires Neo data to be one multi-page TIFF
% and CCD data to be raw .DMCdata
%
% variables:
% ----------
% both: parameters pertinent to both cameras together
% cmos: parameters pertinent to CMOS camera
% ccd: parameters pertinent to CCD camera
%
% algorithm:
% ----------
% 0) get camera file parameters
% 1) chop off non-overlapping parts of video
% 2) for each time step, find the nearest-neighbor frame between the two cameras
% 3) display the joint video in a dynamic updating subplot figure

function [ccd,cmos,both] =  RunSimulPlayFor2013Jan13(varargin)
p = inputParser;
addParamValue(p,'datadir','~/data')
addParamValue(p,'writevid',[]) %#ok<*NVREPL> % need this for Octave 4.0 which doesn't have addParameter
addParamValue(p,'play',true) % show video
parse(p,varargin{:})
U = p.Results;
%%
day2sec = 86400;
both.pbFPS = 20;
both.simKineticSec = 0.06; % arbitrary playback value -- current soft
both.reqStartUT = nan;%datenum([2013 1 13 1 15 35]);
both.reqStopUT = nan;

%rotate CCD data 90 degrees clockwise?
ccd.rot90cw = false;


%rotate CMOS data 90 degrees clockwise?
cmos.rot90cw = true;


% data number scaling
ccd.minVal = 980; %baseline of CCD is 1000 (lowest data number)
ccd.maxVal = 7500;
ccd.stem = [U.datadir,'/2013-01-13T21-00-00_frames_562000-1-568000.DMCdata'];
ccd.kineticSec = 0.02711;
ccd.fullFileStart = datenum([2013 01 13 21 00 00]);
ccd.startUT = ccd.fullFileStart + (562000-1)*ccd.kineticSec/day2sec;

cmos.minVal = 0;
cmos.maxVal = 2800;
cmos.stem = {[U.datadir,'/neo2013-01-13_X38_frames8300-9500.tif']}; %must be a cell
cmos.kineticSec = 0.03008434;
cmos.fullFileStart = datenum([2013 01 13 21 14 34]);
cmos.framesPerFile = 12427;
%remember, CMOS FITS files are named zero-indexed!
cmos.startUT =cmos.fullFileStart + ...
    ((38*cmos.framesPerFile + (8300-1))*cmos.kineticSec )/day2sec;


[ccd,cmos,both] = simulPlay(ccd,cmos,both,U);

end %function

