function AllTick= NeoSpoolScanner(SpoolDir,OutDir,varargin)
% data = NeoSpoolScanner(SpoolDir,OutDir,nRow,nCol,nFramePerSpoolFile,AOIstride,nSkipFile,nMeanFrames,thumbnailWidth,annotateThumbnails)
%
% inputs:
% ------- 
% SpoolDir: where the 100,000 Neo spool files .dat are located
% OutDir: where to place output [] to use SpoolDir
% nRow: number of y-pixels in Neo image--default 640
% nCol: number of x-pixels in Neo image--default 540
% nFramePerSpoolFile: how many frames are in each spool file--default 11
% nSkipFile: take every Nth file, IN ORDER OF FILE NAME--WHICH IS NOT NECESSARILY TIME ORDER!!
% nMeanFrames: to average frames in each spool file for each thumbnail (trying to boost SNR) default nFramePerSpoolFile
% thumbnailWidth: width of thumbnails in pixels (default 128)
% annotateThumbnails: add frame number to each thumbnail (default true)
%
% designed/tested for Octave 3.6 with Cygwin under Windows 7
% Michael Hirsch
% tested to take 5 minutes overall for a 21,000 file directory, taking every 100th file i.e. touching 210 files with mean of all frames in these files.

if ~ismatlab
    pkg load image
    page_screen_output(0);
    page_output_immediately(1);
end

if isempty(OutDir), OutDir = SpoolDir; end

P = length(varargin);
if P>0 && ~isempty(varargin{1}), nRow = varargin{1}; nCol = varargin{2}; 
    else nRow = 640, nCol = 540, end
if P>2 && ~isempty(varargin{3}), nFramePerSpoolFile = varargin{3}; 
    else nFramePerSpoolFile = 11, end
if P>3 && ~isempty(varargin{4}), AOIstride = varargin{4}; 
    else AOIstride = 8, end
if P>4 && ~isempty(varargin{5}), nSkipFile = varargin{5}; 
    else nSkipFile = 100; end

if P>5 && varargin{6}>0 && varargin{6}<=nFramePerSpoolFIle
       nMeanFrames = varargin{6}; 
       else 
       nMeanFrames = nFramePerSpoolFile; 
end

if P>6 && ~isempty(varargin{7}), thumbnailWidth = varargin{7}; 
 else thumbnailWidth = 128; end
 
if P>7 && ~isempty(varargin{8}), annotateThumbnails = varargin{8}; 
else annotateThumbnails=true; end


TempExt = '.tiff'; %'.png';

nRowRaw = nRow + AOIstride;

dTemplate = [SpoolDir,'/*.dat'];
display(['searching directory for: ',dTemplate])
tic
%SpoolFN = dir(dTemplate); %<-- Very slow for 100,000 files!
%use linux to vastly speed up work
[err,SpoolFN2] = unix(['ls ',SpoolDir]);
if err, error(['Could not stat ',SpoolDir]), end
SpoolFN2 = textscan(SpoolFN2,'%s'); 
SpoolFN2 = SpoolFN2{1};
nSpoolFile = length(SpoolFN2);
display(['Retrieved list of ',int2str(nSpoolFile),' spool files in ',...
		num2str(toc,'%0.1f'),' seconds'])
display(['Estimated time to make thumbnail preview montage: ',num2str(nSpoolFile/nSkipFile*300/200 / 60,'%0.1f'),' MINUTES. Have a coffee while waiting.'])
%SpoolFN2 = {SpoolFN.name};


fInd = 1:nSkipFile:nSpoolFile;
nFrameSamp = length(fInd);
AllTick = zeros(nFrameSamp,1,'uint64');

%tempDir = [SpoolDir,'/temp'];
tempDir = '/dev/shm/temp';
mkdir(tempDir);
delete([tempDir,'/*-*spool',TempExt])

display(['Writing ',int2str(nFrameSamp),' sample frames'])

if ismatlab
	dataPrefix = '';
else %is cygwin/octave
	dataPrefix = [SpoolDir,'/'];
end

%take first frame of every 10th file (i.e. every 110th frame)
tic
updateInd = 1;
for i = fInd
	if mod(updateInd,10)==0, display([num2str(i/fInd(end)*100,'%0.1f'),'% complete']), end

    data = zeros(nRow,nCol,nFramePerSpoolFile,'uint16');
    tick64 = zeros(nFramePerSpoolFile,1,'uint64');

    %currFile = [SpoolDir,'/',SpoolFN2{i}]; %when using Matlab/Octave dir()
    currFile = [dataPrefix,SpoolFN2{i}]; % when using linux ls
    fid = fopen(currFile);
    
    if fid>0 && strcmp(currFile(end-3:end),'.dat')
	for j = 1:nMeanFrames

	    %read sample frame from spool data
	    currData = fread(fid,[nRowRaw nCol],'uint16=>uint16',0,'l');
	    %clean zeros out of data
	    data(:,:,j) = currData(1:nRow,:);
	    %get FPGA tick index
	    tick64(j) = NeoSpoolHeader(fid,nRowRaw);
    end
    
    %do mean of frames (time averaging)
    data = mean(data,3); %note this is now class double float!


    [~,SpoolName] = fileparts(currFile);
    
% write thumbnails to disk-using lossless TIF-Packbits -- do not use PNG due to
% RGB colorspace problems (we want grayscale DirectClass)
thumbTick = [tempDir,'/',sprintf('%015d',tick64(1))];
thumbFN =       [thumbTick,'-',SpoolName,TempExt];
thumbFNanno =   [thumbTick,'-anno-',SpoolName,TempExt];

%note: Octave 3.6 doesn't handle imwrite Compression input parameter!
imwrite(imresize(uint16(data),thumbnailWidth/nCol),thumbFN)

% <debug> = ====

%unix(['identify ',thumbFN]);
% =============

% add frame # to thumbnails
if annotateThumbnails
    labeltext = [' -fill black -font Courier-New-Regular',...
	   ' -pointsize 13 -gravity north -annotate 0 "',sprintf('%015d',tick64(1)),'" '];
    %labeltext = ''; %<debug>
    
    mogCmd = ['convert ',thumbFN,labeltext,...
        ' -type GrayScale -colorspace Gray -depth 16 ',thumbFNanno];
    
    if mod(updateInd,50)==0,  display(mogCmd),    end
    mogErr = unix(mogCmd);
    
    if mogErr, warning(['Could not add labels to ',thumbFNanno]), end
end
  
    else
        warning(['file ',currFile,' was unreadable'])
    end %fid>0
    try fclose(fid); end

%keep track of ticks
AllTick((updateInd-1)*nFramePerSpoolFile+1:updateInd*nFramePerSpoolFile) = tick64;

updateInd = updateInd+1;
end %for i

elapsed = toc;
DiffTick = diff(sort(AllTick));

%try
%figure(1),hist(DiffTick,128),set(gca,'yscale','log')
%end

display(['Made thumbnails in ',num2str(elapsed,'%0.1f'),' seconds.'])
display('Making 16-bit montage')
display(['Biggest gap between Neo FPGA ticks was ',int2str(max(DiffTick))])
%% make montage

%make filename

%based off of: http://www.regular-expressions.info/dates.html
try
dateRegStr = '(19|20)\d\d([- /.])(0[1-9]|1[012])\2(0[1-9]|[12][0-9]|3[01])';
[dstri dstpi] = regexp(SpoolDir,dateRegStr,'start','end');
dateStrg = SpoolDir(dstri(end):dstpi(end));
catch %oops, we forgot to use a date when saving spool files
dateStrg='unknownDate';
end
MontPrefix = ['montage-neo-',dateStrg,'-step',int2str(nSkipFile)];

MontFN =        [OutDir,'/',MontPrefix,'-16bit.png'];
MontFNanno =    [OutDir,'/',MontPrefix,'-anno-16bit.png'];

[~,montFNkern] = fileparts(MontFNanno);
MontFNannoText = [OutDir,'/',montFNkern,'.txt'];

%save ticks
display(['saving parameter file: ',MontFNannoText])
save(MontFNannoText,'MontFNanno','AllTick','SpoolFN2','nSkipFile')

%=========annotated montage
montCmd = ['montage ',tempDir,'/*-anno-*spool',TempExt,' ',...
	' -geometry +0+0 -tile 10x -background black ',...
	MontFNanno];
  
display(montCmd)

err = unix(montCmd);

%add comment
textCmd = ['mogrify -set comment "',MontFNannoText,'" ',MontFNanno];
err(2) = unix(textCmd);
if err, error('Could not make 16-bit annotated montage'), end

%====non-annotated montage
%montCmd = ['montage ',tempDir,'/*-anno-*spool',TempExt,' ',...
%      ' -geometry +0+0 -tile 10x -background black ',...
%        MontFN];
  
%display(montCmd)

%err = unix(montCmd);
%if err, error('Could not make 16-bit montage'), end



display('Making 8-bit (labeled) montage via command:')
%make 8-bit montage for convenience
Mont8FN = [OutDir,'/',MontPrefix,'-anno-8bit.png'];
convCmd = ['convert ',MontFNanno,...
       ' -contrast-stretch 3%x0.1% -depth 8 ',...
         Mont8FN];

display(convCmd)

unix(convCmd);

%cleanup RAM drive temp files
delete([tempDir,'/*-*spool.tiff'])

fprintf( '\n*************************************')
fprintf(['\n* Finished at: ',datestr(now),' *'])
fprintf( '\n*************************************\n')


end
