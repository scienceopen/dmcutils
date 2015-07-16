% [data nFrames] = rawDMCreader(fn,moviePlay,nRow,nCol)
% 
% reads uint16 raw data files from DMC
% Tested with Octave 3.8, Matlab R2013b
% Michael Hirsch Dec 2011 / Mar 2012 / Mar 2014
%
% INPUTS:
% fn: filename to read
% nRow: # of height pixels {512}
% nCol: # of width pixels {512}
% playMovie: if ~= 0, play with pause moviePlay seconds
% lowHighClim: for imagesc, sets the upper and lower contrast. E.g. [1000, 1200]
%
% OUTPUTS:
% data: 16-bit data, sorted into frames (view with imagesc)
% nFrames: # of frames
%
% flintmax('double') is 2^53 (biggest integer value we can hold in a
% double float variable in Matlab on a 64-bit Operating System)

function [data, rawFrameInd, nFrame] =...
       rawDMCreader(BigFN,xPix,yPix,xBin,yBin,playMovie,Clim)

if nargin<1, BigFN = '2013-01-13T21-00-00_frames_562000-1-568000.DMCdata'; end
if nargin<2, xPix = 512, yPix = 512, end %#ok<NOPRT> %pixels
if nargin<4, xBin = 4, yBin = 4, end %#ok<NOPRT>
if nargin<4, playMovie = 0.01; end
if nargin<5, Clim = [1000,4000]; end
%% setup data parameters
% based on settings from .xml file (these stay pretty constant)
SuperX = xPix/xBin;
SuperY = yPix/yBin;
BPP = 16; %bits per pixel
nHeadBytes = 4; %bytes per header frame (32 bits for CCD .DMCdata)
nHeader = nHeadBytes/2; % one 16-bit word = 2 bytes
dFormat = 'uint16=>uint16';  %for Andor CCD
fileInfo= dir(BigFN); 
if isempty(fileInfo), error(['file does not exist: ',BigFN]), end
fileSizeBytes = fileInfo.bytes;

if fileSizeBytes > 2e9
    warning(['This will require ',num2str(fileSizeBytes/1e9,'%0.1f'),...
            ' Gigabytes of RAM. Do you have enough RAM?'])
end
BytesPerImage = (SuperX*SuperY*BPP/8);
BytesPerFrame = BytesPerImage + nHeadBytes;
%% get "raw" frame numbers -- that Camera FPGA tags each frame with 
% this raw frame is critical to knowing what time an image was taken, which
% is critical for the usability of this data in light of other sensors
% (radar, optical)
[firstRawInd, lastRawInd] = getRawInd(BigFN,BytesPerImage,nHeadBytes);

nFrame = fileSizeBytes / BytesPerFrame; % by inspection
 %there should be no partial frames
if rem(nFrame,1)
    warning(['Looks like I am not reading this file correctly, with BPF ',int2str(BytesPerFrame)])
end
display([int2str(nFrame),' frames in file ',BigFN])
display(['   file size in Bytes: ',int2str(fileSizeBytes)])
display(['First raw frame # ',int2str(firstRawInd),'.  Last Raw frame # ',...
             int2str(lastRawInd)])

%% preallocate
% note: Matlab's default data type is "double float", which takes 64-bits
% per number. That can use up all the RAM of your PC. The data is only
% 16-bit, so to load bigger files, I keep the data 16-bit.
% In analysis programs, we might convert the data frame-by-frame to double
% or single float as we stream the data through an algorithm.  
% That's because many Matlab functions will crash or give unexpected
% results with integers (or single float!)
data = zeros(SuperX,SuperY,nFrame,'uint16'); 
% I created a custom header, but I needed 32-bit numbers. So I stick two
% 16-bit numbers together when writing the data--Matlab needs to unstick
% and restick this number into a 32-bit integer again.
rawFrameInd = zeros(nFrame,1,'uint32');
%% read data
fid = fopen(BigFN,'r');
if fid<1, error(['error opening ',BigFN]), end

for i = 1:nFrame
    data(:,:,i) = fread(fid,[SuperX,SuperY],dFormat,0,'l'); %first read the image
    metadata = fread(fid,nHeader,dFormat,0,'l'); % we have to typecast this
    %stick two 16-bit numbers together again to make the actual 32-bit raw
    %frame index
    rawFrameInd(i) = typecast( [metadata(2), metadata(1)] ,'uint32'); 
end

fclose(fid);
%% play movie, if user chooses
if playMovie   % ~= 0
  doPlayMovie(data,SuperX,SuperY,nFrame,playMovie,Clim,rawFrameInd)
end %for
end %function

function doPlayMovie(data,nRow,nCol,nFrame,playMovie,Clim,rawFrameInd)
%% setup plot
% note: this will plot slowly in Octave 3.6, but Octave 3.8 with FLTK will
% plot this about as fast as Matlab
    h.f = figure(1); clf(1)
    h.ax = axes('parent',h.f);
    switch isempty(Clim)
        case false, h.im = imagesc(zeros(nRow,nCol,'uint16'),Clim);
        case true,  h.im = imagesc(zeros(nRow,nCol,'uint16'));
    end %switch
   %flip the picture back upright.  Different programs have different ideas
   %about what corner of the image is the origin. Or whether to start indexing at (0,0) or (1,1).
    set(h.ax,'ydir','normal') 
    % just some labels
    h.t = title(h.ax,'');
    colormap(h.ax,'gray')
    h.cb = colorbar('peer',h.ax);
    ylabel(h.cb,'Data Numbers')
    xlabel(h.ax,'x-pixels')
    ylabel(h.ax,'y-pixels')
%% do the plotting    
% setting Cdata like this is much, MUCH faster than repeatedly calling
% imagesc() !
    for iFrame = 1:nFrame
     set(h.im,'cdata',single(data(:,:,iFrame))) %convert to single just as displaying
     set(h.t,'String',...
          ['Raw Frame # ',int2str(rawFrameInd(iFrame)),...
           '    Relative Frame # ',int2str(iFrame)])
     pause(playMovie)
    end
%% cleanup
if nargout==0, clear, end
end %function
