function [ccd, cmos,both] = simulPlay(ccd,cmos,both)
%
% INPUTS:
% -------
% ccd.stem = filename of camera file(s)
% ccd.kineticSec = original camera kinetic time [seconds]
% ccd.startUT = DATENUM format of camera start time in UT
%
% cmos.stem = filename of camera file(s)
% cmos.kineticSec = original camera kinetic time [seconds]
% cmos.startUT = DATENUM format of camera start time in UT
%
% both.simKineticSec  = kinetic rate of 'simulation time' (secoonds) != 1/both.pbFPS
% both.pbFPS = chosen playback FPS (both cameras play nearest neighbor frame to
% this frame rate
%
% this function plays back CCD and sCMOS data at the same time, using the
% "nearest neighbor" frame for each--frames can be repeated during playback, 
% especially if camera frame rates are different from each other.
% e.g. if one camera fps is 1/2 the other camera fps, the first camera
% playback will show the same frame twice for every one of the second
% camera
%
% tested with Matlab R2012b 64-bit on Linux 64-bit and 8GB RAM,
% dual-monitor PC
%
% INPUT FILE FORMAT: intended for use with 16-BIT multipage TIFF grayscale
%
% We assume the PC doesn't have enough RAM to load all the files at once,
% so we load and play frame-by-frame
%
% Michael Hirsch Dec 2012

% uses individual figures to save time--can easily be stitched together via
% uipanel when output specifications are finalized

% example:
% ccd.stem = '/media/small/BigData/Imaging/2012-12-20/CCD/2012-12-20T22-48-34_frames_317600-1-339300.tif';
% ccd.kineticSec = 0.02711; ccd.startUT = datenum([2012 12 21 1 12 04]);
% cmos.stem = '/media/small/BigData/Imaging/2012-12-20/Neo/X109-8bitogv.tif';
% cmos.kineticSec = 0.03030303; cmos.startUT =datenum([2012 12 21 1 17 43]);
%
% both.pbFPS = 10;
% both.simKineticSec = 0.1; %skips frames to speedup playback
% both.reqStartUT = nan; 
% both.reqStopUT = nan;
% [ccd2,cmos2,both2]=simulPlay(ccd,cmos,both)


%% check input
[ccd.dir, ccd.fn, ccd.ext] = fileparts(ccd.stem);
[cmos.dir, cmos.fn, cmos.ext] = fileparts(cmos.stem{1});

if strcmpi('.tif',ccd.ext(1:4)) && strcmpi('.tif',cmos.ext(1:4)) %OK
else error('This program accepts only TIFF files!')
end


%% setup figures
monSize = get(0,'screensize'); monSize = monSize(3:4); %get monitor(s) size

%get TIFF info for sizes
tmp = imfinfo(ccd.stem);
ccd.nFrame = length(tmp);
ccd.tiffinfo = tmp(1);
ccd.nCol = ccd.tiffinfo.Width;
ccd.nRow = ccd.tiffinfo.Height;

tmp = imfinfo(cmos.stem{1});
cmos.nFramePerFile = length(tmp) 
cmos.nFrame = cmos.nFramePerFile .* length(cmos.stem); %length of total rollover files
cmos.tiffinfo = tmp(1);
cmos.nCol = cmos.tiffinfo.Width;
cmos.nRow = cmos.tiffinfo.Height;

%ccd.figPos = [50 monSize(2)-800 600 600];
ccd.figPos = [50 monSize(2)-800 1000 730];
ccd.figH = figure('pos',ccd.figPos,'menubar','none');
%ccd.pbAx = axes('parent',ccd.figH);
ccd.panelPos = [2 100 300 500];
ccd.panelH = uipanel('parent',ccd.figH,'units','pixels','pos',ccd.panelPos);
ccd.pbAx = axes('parent',ccd.panelH);

ccd.imgH = imagesc(1:ccd.nCol,1:ccd.nRow,nan(ccd.nCol,ccd.nRow),...
            [ccd.minVal ccd.maxVal]);
ccd.titleH = title('');
%axis('image')
ccd.cbH = colorbar;
colormap('bone')

%cmos.figPos = [ccd.figPos(1)+ccd.figPos(3)+10 monSize(2)-800 600 600];
%cmos.figH = figure('pos',cmos.figPos,'menubar','none');
%cmos.pbAx = axes('parent',cmos.figH);
cmos.panelH = uipanel('parent',ccd.figH,'units','pixels',...
    'pos',[ccd.panelPos(1)+ccd.panelPos(3)+50 5 700 600]);
cmos.pbAx = axes('parent',cmos.panelH);

if cmos.rot90ccw
cmos.imgH = imagesc(1:cmos.nRow,1:cmos.nCol,nan(cmos.nRow,cmos.nCol),...
            [cmos.minVal cmos.maxVal]);
else
cmos.imgH = imagesc(1:cmos.nCol,1:cmos.nRow,nan(cmos.nCol,cmos.nRow),...
            [cmos.minVal cmos.maxVal]);
end
cmos.titleH = title('');
%axis('image')
cmos.cbH = colorbar;
colormap('bone')

%% synchronize
dnSec = 86400; %maps seconds to datenum unit step

%setup UT times each frame occurred
ccd.stopUT = ccd.startUT+(ccd.nFrame-1)*ccd.kineticSec/dnSec;
ccd.tUT = ccd.startUT:ccd.kineticSec/dnSec:ccd.stopUT;


cmos.stopUT = cmos.startUT+(cmos.nFrame-1)*cmos.kineticSec/dnSec;
cmos.tUT = cmos.startUT:cmos.kineticSec/dnSec:cmos.stopUT;

%determine mutual start/stop frame
both.startUT = max([cmos.startUT ccd.startUT]);
both.stopUT = min([cmos.stopUT ccd.stopUT]);

%make playback time steps
both.tUT = both.startUT:both.simKineticSec/dnSec:both.stopUT;
display(['Mutual frames available from ',datestr(both.startUT),'UT to ',...
    datestr(both.stopUT),'UT'])

%adjust start/stop to user request
both.tUT(both.tUT<both.reqStartUT) = [];
both.tUT(both.tUT>both.reqStopUT) = [];
display('Per user specification, displaying frames from ')
display([datestr(both.tUT(1)),'UT to ',...
    datestr(both.tUT(end)),'UT'])

%flag mutual frame indicies
%ccd.mutFrame = find(ccd.tUT>=both.startUT & ccd.tUT<=both.stopUT);
%cmos.mutFrame= find(cmos.tUT>=both.startUT & cmos.tUT<=both.stopUT);

%use nearest neighbor interpolation to find mutual frames to display
ccd.pbInd = interp1(ccd.tUT,1:ccd.nFrame,both.tUT,'nearest');
cmos.pbInd= interp1(cmos.tUT,1:cmos.nFrame,both.tUT,'nearest');
    
%% playback
display(['virtual playback rate user specified: ',num2str(both.pbFPS),'fps'])
if both.pbFPS>25
    warning(['Unlikely that PC can playback at rate: both.pbFPS=',num2str(both.pbFPS)])
end

display(['Playback kinetic time = ',num2str(both.simKineticSec),' sec.'])
display(['CMOS kinetic time = ',num2str(cmos.kineticSec),' sec.'])
display(['CCD kinetic time = ',num2str(ccd.kineticSec),' sec.'])


for t = 1:length(both.tUT)
 
      
    %update CCD
    ccdFrame = imread(ccd.stem,'index',ccd.pbInd(t));
    if ccd.rot90cw
        ccdFrame = rot90(ccdFrame,-1);
    else %unrotated
    end
    set(ccd.imgH, 'cdata',ccdFrame)
    set(ccd.titleH,'string',['CCD: Time:',...
        datestr(ccd.tUT(ccd.pbInd(t)),'yyyy-mm-ddTHH:MM:SS.fff'),'UT',...
        ' slice: ',int2str(ccd.pbInd(t))])
 %======================   
    %update CMOS
try
      cmosFileInd = fix((cmos.pbInd(t)-1)/cmos.nFramePerFile + 1); %takes integer part

      cmosSliceInd = cmos.pbInd(t) - cmos.nFramePerFile .* (cmosFileInd-1); %handles rollover
      
    cmosFrame = imread(cmos.stem{cmosFileInd},...
                'index',cmosSliceInd);
    if cmos.rot90ccw
        cmosFrame = rot90(cmosFrame,1);
    else %unrotated        
    end
    set(cmos.imgH, 'cdata',cmosFrame)
    set(cmos.titleH,'string',{['CMOS: Time:',...
        datestr(cmos.tUT(cmos.pbInd(t)),'yyyy-mm-ddTHH:MM:SS.fff'),'UT',...
        ' slice: ',int2str(cmosSliceInd)];
        [' file: ',cmos.stem{cmosFileInd}]})
catch
    cmosFileInd
    cmosSliceInd
    cmos.pbInd(t)
    display(lasterr)
end
    
  pause(1/both.pbFPS)
    
 
end

end