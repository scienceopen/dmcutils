function allTick= NeoSpoolScanner(spoolDir,nx,ny,varargin)
% Makes montages of large number of 2015 Andor Solis Neo spool files for
% previewing auroral data, using Octave/Matlab built-in montage() function.

% NOTE: If using Octave 4.0 with Image 2.4.1, you'll need my patch to make
% montage() DisplayRange work:
% https://savannah.gnu.org/bugs/index.php?46259

% inputs:
% ------- 
% spoolDir: where the 100,000 Neo spool files .dat are located
% outDir: where to place output, [] uses SpoolDir
% ny: number of y-pixels in Neo image--default 640
% nx: number of x-pixels in Neo image--default 540
% nFramePerSpoolFile: how many frames are in each spool file--default 11
% nSkipFile: take every Nth file, IN ORDER OF FILE NAME--WHICH IS NOT NECESSARILY TIME ORDER!!
% thumbnailWidth: width of thumbnails in pixels (default 128)
%
% designed/tested for Octave 3.6 with Cygwin under Windows 7
% Michael Hirsch Oct 2012
% tested to take 5 minutes overall for a 21,000 file directory, taking every 100th file i.e. touching 210 files with mean of all frames in these files.

try %for Octave
    pkg load image
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
nFile = length(fInd);
allTick = zeros(nFile*U.nFrameSpool,1,'uint64');

data = zeros(ny,nx,1,nFile,'uint16');
j = 1;
tic
for i = fInd
	if mod(j,10)==0, display([num2str(i/fInd(end)*100,'%0.1f'),'% complete']), end

    [d,t] = readNeoSpool([spoolDir,'/',flist{i}],nx,ny,U.nFrameSpool);
    
    %do mean of frames (time averaging)
    if nFile>1
        data(:,:,1,j) = mean(d,3); 
    else %montage of single file
        for ii = 1:size(d,3)
            data(:,:,1,ii) = d(:,:,ii);
        end
    end

    %keep track of ticks
    allTick((j-1)*U.nFrameSpool+1 : j*U.nFrameSpool) = t;

    j = j+1;
end %for i

dTick = diff(allTick);

disp(['Biggest gap between Neo FPGA ticks was ',int2str(max(dTick))])
disp(['tick mode: ',int2str(mode(dTick))])

%% make filename

%based off of: http://www.regular-expressions.info/dates.html
try
    dateRegStr = '(19|20)\d\d([- /.])(0[1-9]|1[012])\2(0[1-9]|[12][0-9]|3[01])';
    [dstri, dstpi] = regexp(spoolDir,dateRegStr,'start','end');
    dateStrg = spoolDir(dstri(end):dstpi(end));
catch %oops, we forgot to use a date when saving spool files
    dateStrg='unknownDate';
end

MontPrefix = ['montage-neo-',dateStrg,'-step',int2str(U.skipNfile)];
montfn = [U.outdir,'/',MontPrefix,'.png'];
[~,basemont] = fileparts(montfn);
matfn = [U.outdir,'/',basemont,'.mat'];

%save ticks
disp(['saving parameter file: ',matfn])
save(matfn,'allTick','flist')

%% create montage image
clim = prctile(single(data(:)).',[1,99.9]); % single() needed for Matlab R2015b et al, .' needed for Octave 4.0
disp(['climming montage to ',num2str(clim)])
h=montage(data,'DisplayRange',clim);

if ~nargout,clear,end
end %function