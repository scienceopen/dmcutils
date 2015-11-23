function [ccd, cmos] = timeMogrify(ccd,cmos)

%inputs:
% ccd.startUT: datenum formatted time that CCD datafile starts
% ccd.kineticSec: kinetic rate of CCD (seconds)
% ccd.startFrame: first frame you want to have from both CCD and CMOS
% ccd.stopFrame: last frame you want to "" "" "" ""
%
% cmos.startUT: datenum formatted time that CMOS camera started (not per file) in ImageJ, <ctrl> I, see FRAME
% cmos.kineticSEc: kinetic rate of CMOS (seconds) see ImageJ, <ctrl> I, see KCT
% cmos.framesPerFile: # of frames per FITS file (get by opening first or any file in ImageJ and press <ctrl> I, see NAXIS3
%
% example:
% ccd.startUT = datenum([2013 01 13 21 00 00]); ccd.kineticSec = 0.02711;
% cmos.startUT = datenum([2013 01 13 21 14 34]); cmos.kineticSec = 0.03008434;
% cmos.framesPerFile = 12427;
% ccd.startFrame = 562000; ccd.stopFrame = 568000;
% [ccd,cmos] = timeMogrify(ccd,cmos)


day2sec = 86400;

ccd.extractStartUT = ccd.startUT + (ccd.startFrame-1) *ccd.kineticSec/day2sec;
ccd.extractStopUT = ccd.startUT + (ccd.stopFrame-1) *ccd.kineticSec/day2sec;

%neo X??? files are zero-indexed named!
%cmos.startOffsetSec = cmos.startUT - ccd.startUT; 

cmos.SecPerFile = cmos.kineticSec * cmos.framesPerFile;

cmos.extractStartFile = (ccd.extractStartUT - cmos.startUT) / (cmos.SecPerFile/day2sec);
cmos.extractStopFile = (ccd.extractStopUT - cmos.startUT) / (cmos.SecPerFile/day2sec);

end
