function [ccd, cmos,both] = simulPlay(ccd,cmos,both,U)
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
% writevid: give filename of frame capture you want to write to disk
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

% example:
% ccd.stem = '2012-12-20/CCD/2012-12-20T22-48-34_frames_317600-1-339300.tif';
% ccd.kineticSec = 0.02711; ccd.startUT = datenum([2012 12 21 1 12 04]);
% cmos.stem = '2012-12-20/Neo/X109-8bitogv.tif';
% cmos.kineticSec = 0.03030303; cmos.startUT =datenum([2012 12 21 1 17 43]);
%
% both.pbFPS = 10;
% both.simKineticSec = 0.1; %skips frames to speedup playback
% both.reqStartUT = nan;
% both.reqStopUT = nan;
% [ccd2,cmos2,both2]=simulPlay(ccd,cmos,both)
%% check input
if ~exist(ccd.stem,'file')
    warn(['could not find ',ccd.stem])
    ccd = []
else
    ccd = setupccd(ccd);
end
if ~exist(cmos.stem{1},'file')
    warning(['could not find ',cmos.stem{1}])
    cmos = []
else
    cmos = setupcmos(cmos);
end
%% setup figures
[ccd,cmos,fig,hvid] = setupfig(ccd,cmos,U.writevid,U.play);
%% synchronize
[ccd,cmos,both] = synccam(ccd,cmos,both);
%% playback
%display(['virtual playback rate user specified: ',num2str(both.pbFPS),'fps'])

display(['Playback kinetic time = ',num2str(both.simKineticSec),' sec.'])
display(['CMOS kinetic time = ',num2str(cmos.kineticSec),' sec.'])
display(['CCD kinetic time = ',num2str(ccd.kineticSec),' sec.'])
%% loop video
playvideo(ccd,cmos,both,fig,hvid)

end %function

function ccd = setupccd(ccd)
if isempty(ccd), return, end

[ccd.dir, ccd.fn, ccd.ext] = fileparts(ccd.stem);

switch ccd.ext
    case '.tif'
      tmp = imfinfo(ccd.stem);
      ccd.nFrame = length(tmp);
      ccd.tiffinfo = tmp(1);
      ccd.nCol = ccd.tiffinfo.Width;
      ccd.nRow = ccd.tiffinfo.Height;
    case '.DMCdata'
      info = dir(ccd.stem); %get info about the file
      fileSizeBytes = info.bytes;

      xPixels=512;
      yPixels=512;
      xBin = 4;
      yBin = 4;
      ccd.nHead16 = 2; %# of 16-bit header elements
      nHeadBytes = 2 * ccd.nHead16;
      SuperX = xPixels/xBin;
      SuperY = yPixels/yBin;
      BitsPerPixel = 16;
      BitsPerByte = 8;
      ccd.BytesPerFrame = SuperX * SuperY * BitsPerPixel/BitsPerByte + nHeadBytes;

      ccd.nFrame = fileSizeBytes / ccd.BytesPerFrame;
      ccd.nCol = SuperX;
      ccd.nRow = SuperY;
end %switch

end %function

function cmos = setupcmos(cmos)
if isempty(cmos), return, end

% assumes that CMOS is always .tif saved from Solis
[cmos.dir, cmos.fn, cmos.ext] = fileparts(cmos.stem{1});

tmp = imfinfo(cmos.stem{1});
cmos.nFramePerFile = length(tmp);
cmos.nFrame = cmos.nFramePerFile .* length(cmos.stem); %length of total rollover files
cmos.tiffinfo = tmp(1);
cmos.nCol = cmos.tiffinfo.Width;
cmos.nRow = cmos.tiffinfo.Height;

end %function

function [ccd,cmos,fig,hvid] = setupfig(ccd,cmos,writevid,play)
if ~play
    fig = []; hvid=[];
    return
end


figPos = [50 50 1000 500];
fig = figure('position',figPos,'menubar','none');

if ~isempty(ccd)
    ccd.panelPos = [2 100 400 300];
    ccd.panelH = uipanel('parent',fig,'units','pixels','position',ccd.panelPos);
    ccd.pbAx = axes('parent',ccd.panelH);

    ccd.imgH = imagesc(1:ccd.nCol,1:ccd.nRow,nan(ccd.nCol,ccd.nRow),...
                [ccd.minVal ccd.maxVal]);
    ccd.titleH = title('','interpreter','none');

    ccd.cbH = colorbar;
    set(get(ccd.cbH,'ylabel'),'string','CCD 14-bit data numbers [0..16384]')
end

if ~isempty(cmos)
    cmos.panelH = uipanel('parent',fig,'units','pixels',...
        'position',[ccd.panelPos(1)+ccd.panelPos(3)+10 5 600 500]);
    cmos.pbAx = axes('parent',cmos.panelH);

    if cmos.rot90cw
    cmos.imgH = imagesc(1:cmos.nCol,1:cmos.nRow,nan(cmos.nRow,cmos.nCol),...
                [cmos.minVal cmos.maxVal]);
    else
    cmos.imgH = imagesc(1:cmos.nCol,1:cmos.nRow,nan(cmos.nRow,cmos.nCol),...
                [cmos.minVal cmos.maxVal]);
    end
    cmos.titleH = title('','interpreter','none');

    cmos.cbH = colorbar;
    colormap('gray')
    set(get(cmos.cbH,'ylabel'),'string','sCMOS 16-bit data numbers [0..65535]')
end

if ~isempty(writevid)
   hvid = VideoWriter(writevid,'Uncompressed AVI');
   open(hvid)
else
   hvid=[];
end

end %function

function [ccd,cmos,both] = synccam(ccd,cmos,both)
day2sec = 86400; %maps seconds to datenum unit step

try
    ccd.stopUT = ccd.startUT+(ccd.nFrame-1)*ccd.kineticSec/day2sec;
    ccd.tUT = ccd.startUT:ccd.kineticSec/day2sec:ccd.stopUT;
catch e
     warning(['problem using ccd  ',e.message])
end

try
    cmos.stopUT = cmos.startUT+(cmos.nFrame-1)*cmos.kineticSec/day2sec;
    cmos.tUT = cmos.startUT:cmos.kineticSec/day2sec:cmos.stopUT;
catch e
    warning(['problem using cmos  ',e.message])
end

%determine mutual start/stop frame
both.startUT = max([cmos.startUT ccd.startUT]); %who started last
both.stopUT = min([cmos.stopUT ccd.stopUT]); %who ends first

%make playback time steps
both.tUT = both.startUT:both.simKineticSec/day2sec:both.stopUT;
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

end %function

function playvideo(ccd,cmos,both,fig,hvid)
if isempty(fig)
disp('skipping video playback per user request')
return
end

try
    t=[]; cmosFileInd=[]; cmosSliceInd=[]; %in case loop not entered

    if strcmp(ccd.ext,'.DMCdata'),
        fid = fopen(ccd.stem);
        %seek to first frame
        fseek(fid,(ccd.pbInd(1) - 1) * ccd.BytesPerFrame,'bof');
    end

    for t = 1:length(both.tUT)

        %update CCD
        switch ccd.ext
            case '.tif', ccdFrame = imread(ccd.stem,'index',ccd.pbInd(t));
            case '.DMCdata'
                ccdFrame = rot90(fread(fid,[ccd.nRow ccd.nCol],'uint16=>uint16',0,'l').',1);
                metadata = fread(fid,ccd.nHead16,'uint16=>uint16',0,'l');
                ccd.frameInd = typecast([metadata(2) metadata(1)],'uint32');
        end
        if ccd.rot90cw
            ccdFrame = rot90(ccdFrame,-1);
        else %unrotated
        end
        set(ccd.imgH, 'cdata',ccdFrame)
        set(ccd.titleH,'string',{['CCD: ',...
            datestr(ccd.tUT(ccd.pbInd(t)),'yyyy-mm-ddTHH:MM:SS.FFF'),'UT',...
            ' frame: ',int2str(ccd.frameInd)];...
            ['file: ',ccd.stem]})
     %======================
        %update CMOS

          cmosFileInd = fix((cmos.pbInd(t)-1)/cmos.nFramePerFile + 1); %takes integer part

          cmosSliceInd = cmos.pbInd(t) - cmos.nFramePerFile .* (cmosFileInd-1); %handles rollover

        cmosFrame = imread(cmos.stem{cmosFileInd},  'index',cmosSliceInd);
      %=== orientation correction ==
        if cmos.rot90cw
            cmosFrame = rot90(cmosFrame,-1);
        else %unrotated
        end

      %=============================
        set(cmos.imgH, 'cdata',cmosFrame)
        set(cmos.titleH,'string',{['CMOS: ',...
            datestr(cmos.tUT(cmos.pbInd(t)),'yyyy-mm-ddTHH:MM:SS.FFF'),'UT',...
            ' slice: ',int2str(cmosSliceInd)];...
            [' file: ',cmos.stem{cmosFileInd}]})


      if ~isempty(hvid)
         I = getframe(fig);
         writeVideo(hvid,I)
      end
      pause(1/both.pbFPS)

    end %for t
catch e
    cmosFileInd %#ok<*NOPRT>
    cmosSliceInd
    cmos.pbInd(t)
    display(e.message)
end %try

try close(hvid), end

try fclose(fid); end


end %function