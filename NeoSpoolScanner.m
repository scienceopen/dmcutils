function allTick= NeoSpoolScanner(spoolDir,nx,ny,varargin)
% Makes montages of large number of 2015 Andor Solis Neo spool files for
% previewing auroral data, using Octave/Matlab built-in montage() function

% inputs:
% ------- 
% SpoolDir: where the 100,000 Neo spool files .dat are located
% OutDir: where to place output, [] uses SpoolDir
% nRow: number of y-pixels in Neo image--default 640
% nCol: number of x-pixels in Neo image--default 540
% nFramePerSpoolFile: how many frames are in each spool file--default 11
% nSkipFile: take every Nth file, IN ORDER OF FILE NAME--WHICH IS NOT NECESSARILY TIME ORDER!!
% nMeanFrames: to average frames in each spool file for each thumbnail (trying to boost SNR) default nFramePerSpoolFile
% thumbnailWidth: width of thumbnails in pixels (default 128)
% annotateThumbnails: add frame number to each thumbnail (default true)
%
% designed/tested for Octave 3.6 with Cygwin under Windows 7
% Michael Hirsch Oct 2012
% tested to take 5 minutes overall for a 21,000 file directory, taking every 100th file i.e. touching 210 files with mean of all frames in these files.

try %for Octave
    page_screen_output(0);
    page_output_immediately(1);
end
%% user parameters
p = inputParser;
addOptional(p,'outdir',spoolDir)
addOptional(p,'nFrameSpool',12) % for 2012-2013 Solis, was 11 ...
addOptional(p,'AOIstride',8) %always 8?
addOptional(p,'colfirst',true) %false for 2012-2013 Solis?, true for 2015 Solis
addOptional(p,'thumbnailwidth',128) %for montage, each image
addOptional(p,'skipNfile',10) %every Nth file
parse(p,varargin{:})
U = p.Results;
%% get file list
dTemplate = [spoolDir,'/*spool.dat'];
display(['searching: ',dTemplate])
tic
flist = dir(dTemplate); %<-- Very slow for 100,000 files!
%use linux to vastly speed up work
%[err,SpoolFN2] = unix(['ls ',spoolDir]);
%if err, error(['Could not stat ',spoolDir]), end
%SpoolFN2 = textscan(SpoolFN2,'%s'); 
%SpoolFN2 = SpoolFN2{1};
nSpool = length(flist);
display(['Retrieved list of ',int2str(nSpool),' spool files in ',...
		num2str(toc,'%0.1f'),' seconds'])
flist={flist.name};

fInd = 1:U.skipNfile:nSpool;
nFrameSamp = length(fInd);
allTick = zeros(nFrameSamp,1,'uint64');

%take first frame of every Nth file (i.e. every (P*N)th frame)
tic
j = 1;
for i = fInd
	if mod(j,10)==0, display([num2str(i/fInd(end)*100,'%0.1f'),'% complete']), end

    data = zeros(ny,nx,1,nFrameSamp,'uint16');

    [d,t] = readNeoSpool([spoolDir,filesep,flist{i}],nx,ny,'nFrame',U.nFrameSpool);
    
    %do mean of frames (time averaging)
    data(:,:,1,j) = mean(d,3); %note this is now class double float!

    %keep track of ticks
    allTick((j-1)*U.nFrameSpool+1 : j*U.nFrameSpool) = t;

    j = j+1;
end %for i

DiffTick = diff(sort(allTick));

disp(['Biggest gap between Neo FPGA ticks was ',int2str(max(DiffTick))])
disp(['tick mode: ',int2str(mode(DiffTick))])
%% make montage

%make filename

%based off of: http://www.regular-expressions.info/dates.html
try
dateRegStr = '(19|20)\d\d([- /.])(0[1-9]|1[012])\2(0[1-9]|[12][0-9]|3[01])';
[dstri dstpi] = regexp(spoolDir,dateRegStr,'start','end');
dateStrg = spoolDir(dstri(end):dstpi(end));
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
