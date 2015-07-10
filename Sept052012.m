clc
clear all

ccd.startUT = datenum([2012 11 15 21 00 00]);
ccd.startFrame = 1307488;%1145221;
ccd.stopFrame = 1307488+3064;%1160662;
ccd.kineticSec= 0.01632;

cmos.startUT = datenum([2012 11 15 23 44 06]);
cmos.framesPerFile = 3106;
cmos.kineticSec = 0.1;

[ccd, cmos] = timeMogrify(ccd,cmos);

display(['CCD extract frame ',int2str(ccd.startFrame),' start: ',datestr(ccd.extractStartUT)])
display(['CCD extract frame ',int2str(ccd.stopFrame),' stop: ',datestr(ccd.extractStopUT)])

display('corresponding CMOS data')
display(['CMOS start file extension: X',num2str(cmos.extractStartFile)])
display(['CMOS stop file extension: X',num2str(cmos.extractStopFile)])